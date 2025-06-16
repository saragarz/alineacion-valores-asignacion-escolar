:- module(_,[main/2, cargar_csv_solicitudes/1, datos/1, punt_no_arte/2]).

:- use_module(library(csv)).
:- dynamic datos/1.

cargar_csv_solicitudes(Path) :-
    csv_read_file(Path, [_|R], [
        separator(0';),
        arity(38)
    ]),
    maplist(row_to_list, R, Solicitudes),
    assertz(datos(Solicitudes)).

row_to_list(Row, Lista) :-
    Row =.. [row | Lista].

main(Path, MapPath) :-
    cargar_csv_solicitudes(Path),
    datos(S0),
    mapea(S0,S1),
    guardar_csv_solicitudes(S1, MapPath).

mapea([],[]).
mapea([S0|S0s],[S1|S1s]) :-
    mapea_student(S0,S1),
    mapea(S0s,S1s).

mapea_student([A1, A2, A3, A4, A5, _, _, _, _, A10, A11, A12, _, A14, A15,
_, _, _, _, A20, A21, A22, A23, A24, A25, A26, A27, A28, A29, A30, A31,
A32, A33, A34, A35, A36, A37, A38], [B1, B2, B3, B4, B5, B10, B11,
B12, B14, B15, B20, B21, B22, B23, B24, B25, B26, B27, B28, B29,
B30, B31, B32, B33, B34, B35, B36, B37, B38]) :-
    estudiante(A1,B1),
    curso(A2,B2),
    prioridad(A3,B3),
    codigo_centro(A4,B4),
    nombre_centro(A5,B5),
    provincia_baremo(A10,B10),
    municipio_baremo(A11,B11),
    distrito_baremo(A12,B12),
    codigo_centro_admision(A14,B14),
    nombre_centro_admision(A15,B15),
    admitido(A20,B20),
    renuncia(A21,B21),
    desestimada(A22,B22),
    matriculado(A23,B23),
    renta_minima(A24,B24),
    discapacidad(A25,B25),
    nota_media(A26,B26, [A2,A1]), %%% necesita info adicional
    familia_numerosa(A27,B27),
    domicilio(A28,B28),
    antiguo_alumno(A29,B29),
    criterio_centro(A30,B30),
    hermanos_matriculados(A31,B31),
    tutor_trabajando(A32,B32),
    parto_multiple(A33,B33),
    familia_monoparental(A34,B34),
    acogida(A35,B35),
    violencia_genero(A36,B36),
    puntuacion_total(A37,B37),
    fecha_solicitud(A38,B38).

estudiante(A1,A1).
curso(A2,A2).
prioridad(A3,A3).
codigo_centro(A4,A4).
nombre_centro(A5,A5).

provincia_baremo(A10,A10).
municipio_baremo(A11,A11).
distrito_baremo(A12,A12).

codigo_centro_admision(A14,A14).
nombre_centro_admision(A15,A15).

admitido(A20,A20).
renuncia(A21,A21).
desestimada(A22,A22).
matriculado(A23,A23).

%%% complicada %%%
nota_media(A26,B26,[Curso,Alumno]) :-
    bachillerato_arte(Curso),
    map_nota_arte(A26,B26,Alumno), !.
nota_media(A26,B26,[Curso,_]) :-
    bachillerato_no_arte(Curso),
    map_nota_no_arte(A26,B26), !.
nota_media(_,'Sin información', _).

bachillerato_arte('1º de Bachillerato (Artes (Artes Plásticas, Imagen y Diseño))  LOMLOE').
bachillerato_arte('1º de Bachillerato (Artes (Música y Artes Escénicas)) LOMLOE').
bachillerato_arte('2º de Bachillerato (Artes (Artes Plásticas, Imagen y Diseño))  LOMLOE').
bachillerato_arte('2º de Bachillerato (Artes (Música y Artes Escénicas)) LOMLOE').

bachillerato_no_arte('1º de Bachillerato (Ciencias y Tecnología) LOMLOE').
bachillerato_no_arte('1º de Bachillerato (General) LOMLOE').
bachillerato_no_arte('1º de Bachillerato (Humanidades y Ciencias Sociales) LOMLOE').
bachillerato_no_arte('2º de Bachillerato (Ciencias y Tecnología) LOMLOE').
bachillerato_no_arte('2º de Bachillerato (General) LOMLOE').
bachillerato_no_arte('2º de Bachillerato (Humanidades y Ciencias Sociales) LOMLOE').

map_nota_arte(0.0, '<6', _).
map_nota_arte(0.5, '<6 + artes 0.5',_).
map_nota_arte(1.0, '<6 + artes 1', _).
map_nota_arte(1.5, '<6 + artes 1.5', _).
map_nota_arte(6.0, '[6,7)', _).
map_nota_arte(6.5, '[6,7) + artes 0.5', _).

map_nota_arte(7.0, '[6,7) + artes 1', Alumno) :-
    punt_no_arte(Alumno, 6.0), !.
map_nota_arte(7.0, '[7,8)', Alumno) :-
    punt_no_arte(Alumno, 7.0), !.
map_nota_arte(7.0, '[6,7) + artes 1 o [7,8)',_).

map_nota_arte(7.5, '[6,7) + artes 1.5', Alumno) :-
    punt_no_arte(Alumno, 6.0), !.
map_nota_arte(7.5, '[7,8) + artes 0.5', Alumno) :-
    punt_no_arte(Alumno, 7.0), !.
map_nota_arte(7.5, '[6,7) + artes 1.5 o [7,8) + artes 0.5',_).

map_nota_arte(8.0, '[7,8) + artes 1',_).
map_nota_arte(8.5, '[7,8) + artes 1.5', _).
map_nota_arte(9.0, '[8,9)', _).
map_nota_arte(9.5, '[8,9) + artes 0.5', _).
map_nota_arte(10.0, '[8,9) + artes 1', _).
map_nota_arte(10.5, '[8,9) + artes 1.5', _).
map_nota_arte(11.0, '>=9', _).
map_nota_arte(11.5, '>=9 + artes 0.5', _).
map_nota_arte(12.0, '>=9 + artes 1', _).
map_nota_arte(12.5, '>=9 + artes 1.5', _).

map_nota_no_arte(11.0, '>=9').
map_nota_no_arte(9.0, '[8,9)').
map_nota_no_arte(7.0, '[7,8)').
map_nota_no_arte(6.0, '[6,7)').
map_nota_no_arte(0.0, '<6').

punt_no_arte(A1, A26) :-
    datos(S0),
    bachillerato_no_arte(A2),
    member([A1, A2, _A3, _A4, _A5, _A6, _A7, _A8, _A9, _A10, _A11, _A12, _A13,
    _A14, _A15, _A16, _A17, _A18, _A19, _A20, _A21, _A22, _A23, _A24, _A25, A26,
     _A27, _A28, _A29, _A30, _A31, _A32, _A33, _A34, _A35, _A36, _A37, _A38],
     S0).

renta_minima(2, 'Sí').
renta_minima(0, 'No').

discapacidad(7, 'Sí').
discapacidad(0, 'No').

familia_numerosa(11, 'Especial').
familia_numerosa(10, 'General').
familia_numerosa(0, 'No').

domicilio(13, 'Mismo distrito').
domicilio(12, 'Mismo municipio').
domicilio(8, 'Comunidad de Madrid').
domicilio(0, 'Extracomunitario').

antiguo_alumno(4, 'Sí').
antiguo_alumno(0, 'No').

criterio_centro(3, 'Se cumple').
criterio_centro(0, 'No se cumple').

hermanos_matriculados(30, 'Dos o más').
hermanos_matriculados(15, 'Uno').
hermanos_matriculados(0, 'Cero').

tutor_trabajando(10, 'Sí').
tutor_trabajando(0, 'No').

parto_multiple(3, 'Sí').
parto_multiple(0, 'No').

familia_monoparental(3, 'Sí').
familia_monoparental(0, 'No').

acogida(3, 'Sí').
acogida(0, 'No').

violencia_genero(2, 'Sí').
violencia_genero(0, 'No').

puntuacion_total(A37,A37).
fecha_solicitud(A38,A38).

list_to_fila(
    [A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,
     A11,A12,A13,A14,A15,A16,A17,A18,A19,A20,
     A21,A22,A23,A24,A25,A26,A27,A28,A29],
    row(A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,
         A11,A12,A13,A14,A15,A16,A17,A18,A19,A20,
         A21,A22,A23,A24,A25,A26,A27,A28,A29)
).

guardar_csv_solicitudes(Solicitudes, NombreArchivo) :-
    maplist(list_to_fila, Solicitudes, Filas),
    Cabecera = row('estudiante','curso','prioridad','codigo_centro',
                    'nombre_centro','provincia_baremo','municipio_baremo','distrito_baremo',
                    'codigo_centro_adm','nombre_centro_adm','admitido','renuncia','desestimada',
                    'matriculado','RenMin', 'Dis', 'NotMed', 'FamNum', 'Dom', 'AntAlu', 'Cen',
                    'HerMat', 'TutTra', 'ParMul', 'FamMon', 'Acog', 'VioGen', 'puntuacion_total',
                    'fecha'),
    csv_write_file(NombreArchivo, [Cabecera | Filas], [separator(0';)]).