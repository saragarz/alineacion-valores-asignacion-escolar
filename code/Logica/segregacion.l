# GENERAL
SolicitudAdmitida(estudiante:, curso:, prioridad:, codigo_colegio:codigo_centro,
    nombre_colegio: nombre_centro, provincia_baremo:, municipio_baremo:,
    distrito_baremo:, admitido:, renuncia:, rechazado:, matriculado:,
    puntuacion_renta_minima:, puntuacion_discapacidad:, puntuacion_media_academica:,
    puntuacion_familia_numerosa:, puntuacion_residencia:, puntuacion_antiguo_alumno:,
    puntuacion_criterio_colegio:puntuacion_criterio_centro,
    puntuacion_hermanos_matriculados:,
    puntuacion_tutor_trabajando:, puntuacion_parto_multiple:, puntuacion_familia_monoparental:,
    puntuacion_acogida:, puntuacion_violencia_genero:, puntuacion_total:, fecha:) :-
    Solicitud(estudiante:, curso:, prioridad:, codigo_centro:, nombre_centro:,
        provincia_baremo:, municipio_baremo:, distrito_baremo:,
        codigo_centro_adm:, admitido:, renuncia:, rechazado:,
        matriculado:, puntuacion_renta_minima:, puntuacion_discapacidad:,
        puntuacion_media_academica:, puntuacion_familia_numerosa:, puntuacion_residencia:,
        puntuacion_antiguo_alumno:, puntuacion_criterio_centro:,
        puntuacion_hermanos_matriculados:,
        puntuacion_tutor_trabajando:, puntuacion_parto_multiple:,
        puntuacion_familia_monoparental:,
        puntuacion_acogida:, puntuacion_violencia_genero:, puntuacion_total:, fecha:),
    Like(curso, "%Tres%"),
    #curso == "Tres Años",
    codigo_centro == codigo_centro_adm;

TotalEstudiantes(estudiantes? += 1) distinct :-
    SolicitudAdmitida(estudiante:);

RentaMinima(renta_minima: "Sí", puntuacion_renta_minima: 2);
EstudianteGrupoMinoritario(estudiante:) distinct :-
    Solicitud(estudiante:, puntuacion_renta_minima:),
    RentaMinima(renta_minima: "Sí", puntuacion_renta_minima:);

TotalEstudiantesGrupoMinoritario(estudiantes? += 1) distinct :-
    EstudianteGrupoMinoritario(estudiante:),
    SolicitudAdmitida(estudiante:);

ValorSegregacion(valor_segregacion:, minoritarios_i:, minoritarios:, total_i:, total:) :-
    minoritarios > 0,
    valor_segregacion == minoritarios_i/minoritarios - total_i/total;

# COLEGIOS
TotalEstudiantesColegio(estudiantes? += 1, codigo_colegio:, nombre_colegio:) distinct :-
     SolicitudAdmitida(estudiante:, codigo_colegio:, nombre_colegio:);

 @OrderBy(EstudiantesMinoritariosColegio, "estudiantes desc");
 EstudiantesMinoritariosColegio(estudiantes:, codigo_colegio:, nombre_colegio:) distinct :-
     EstudiantesMinoritariosColegioConteo(estudiantes:, codigo_colegio:, nombre_colegio:) |
     EstudiantesMinoritariosColegioPorDefecto(estudiantes:, codigo_colegio:, nombre_colegio:);

 EstudiantesMinoritariosColegioConteo(estudiantes? += 1, codigo_colegio:, nombre_colegio:) distinct :-
     SolicitudAdmitida(estudiante:, codigo_colegio:, nombre_colegio:),
     EstudianteGrupoMinoritario(estudiante:);

 EstudiantesMinoritariosColegioPorDefecto(estudiantes: 0, codigo_colegio:, nombre_colegio:) distinct :-
     ~EstudiantesMinoritariosColegioConteo(codigo_colegio:),
     TotalEstudiantesColegio(codigo_colegio:, nombre_colegio:);

CoordenadasColegio(x:, y:, codigo_colegio:) :-
    Colegio(codigo_colegio:, coordenada_x_direccion:x, coordenada_y_direccion:y);

DistanciaColegios(distancia:, codigo_colegio1:, codigo_colegio2:) :-
    CoordenadasColegio(x:x1, y:y1, codigo_colegio:codigo_colegio1),
    CoordenadasColegio(x:x2, y:y2, codigo_colegio:codigo_colegio2),
    Distancia(distancia:, x1:, y1:, x2:, y2:);

Distancia(distancia:, x1:, y1:, x2:, y2:) :-
    distancia = Sqrt((x1 - x2)^2 + (y1 - y2)^2);

NombreTipoColegio(nombre_tipo_colegio:tipo_desc_abreviado++" "++nombre_colegio, codigo_colegio:) :-
    Colegio(codigo_colegio:, nombre_colegio:, tipo_desc_abreviado:);

# MUNICIPIOS
TotalEstudiantesMunicipio(estudiantes? += estudiantes_colegio, municipio:) distinct :-
    TotalEstudiantesColegio(estudiantes:estudiantes_colegio, codigo_colegio:),
    Colegio(codigo_colegio:, nombre_municipio:municipio);

@OrderBy(EstudiantesMinoritariosMunicipio, "estudiantes desc");
EstudiantesMinoritariosMunicipio(estudiantes? += estudiantes_colegio, municipio:) distinct :-
    EstudiantesMinoritariosColegio(estudiantes:estudiantes_colegio, codigo_colegio:),
    Colegio(codigo_colegio:, nombre_municipio:municipio);

# COLEGIOS CAM
SegregacionDesagregada(valor_segregacion:, minoritarios_n:, minoritarios:, total_n:, total:) :-
    minoritarios > 0,
    valor_segregacion == minoritarios_n/minoritarios - total_n/total;

SegregacionColegiosCAM(valor_segregacion? += 0.5*Abs(segregacion_colegio),
estudiantes_minoritarios:, estudiantes:total)
distinct :-
    TotalEstudiantesGrupoMinoritario(estudiantes:estudiantes_minoritarios),
    TotalEstudiantes(estudiantes:total),
    EstudiantesMinoritariosColegio(estudiantes:estudiantes_minoritarios_colegio, codigo_colegio:),
    TotalEstudiantesColegio(estudiantes:total_estudiantes_colegio, codigo_colegio:),
    SegregacionDesagregada(valor_segregacion:segregacion_colegio, minoritarios_n:estudiantes_minoritarios_colegio, minoritarios:estudiantes_minoritarios, total_n:total_estudiantes_colegio, total:);

#@OrderBy(SegregacionColegioCAM, "valor_segregacion");
SegregacionColegioCAM(valor_segregacion:, codigo_colegio:, nombre_colegio:,
estudiantes_minoritarios_colegio:, total_estudiantes_colegio:) :-
    Colegio(codigo_colegio:, nombre_colegio:),
    EstudiantesMinoritariosColegio(estudiantes:estudiantes_minoritarios_colegio, codigo_colegio:),
    TotalEstudiantesColegio(estudiantes:total_estudiantes_colegio, codigo_colegio:),
    TotalEstudiantesGrupoMinoritario(estudiantes:estudiantes_minoritarios),
    TotalEstudiantes(estudiantes:total),
    SegregacionDesagregada(valor_segregacion:, minoritarios_n:estudiantes_minoritarios_colegio, minoritarios:estudiantes_minoritarios, total_n:total_estudiantes_colegio, total:);


# MUNICIPIOS CAM
SegregacionMunicipiosCAM(valor_segregacion? += 0.5*Abs(segregacion_municipio),
estudiantes_minoritarios:, estudiantes:total)
distinct :-
    TotalEstudiantesGrupoMinoritario(estudiantes:estudiantes_minoritarios),
    TotalEstudiantes(estudiantes:total),
    EstudiantesMinoritariosMunicipio(estudiantes:estudiantes_minoritarios_municipio, municipio:),
    TotalEstudiantesMunicipio(estudiantes:total_estudiantes_municipio,
    municipio:),
    SegregacionDesagregada(valor_segregacion:segregacion_municipio,
    minoritarios_n:estudiantes_minoritarios_municipio,
    minoritarios:estudiantes_minoritarios, total_n:total_estudiantes_municipio,
    total:);

@OrderBy(SegregacionMunicipioCAM, "valor_segregacion desc");
SegregacionMunicipioCAM(valor_segregacion:, municipio:,
estudiantes_minoritarios_municipio:,
    total_estudiantes_municipio:) :-
    EstudiantesMinoritariosMunicipio(estudiantes:estudiantes_minoritarios_municipio, municipio:),
    TotalEstudiantesMunicipio(estudiantes:total_estudiantes_municipio, municipio:),
    TotalEstudiantesGrupoMinoritario(estudiantes:estudiantes_minoritarios),
    TotalEstudiantes(estudiantes:total),
    SegregacionDesagregada(valor_segregacion:,
    minoritarios_n:estudiantes_minoritarios_municipio,
    minoritarios:estudiantes_minoritarios, total_n:total_estudiantes_municipio,
    total:);

PoligonoMunicipio(poligono:, municipio:) :-
    GeometriaMunicipio(NAMEUNIT: municipio, geometry:poligono);

# COLEGIOS MUNICIPIO
@OrderBy(SegregacionColegiosMunicipio, "valor_segregacion desc");
SegregacionColegiosMunicipio(valor_segregacion? += 0.5*Abs(segregacion_colegio), municipio:, estudiantes_minoritarios:, estudiantes:total) distinct :-
    EstudiantesMinoritariosMunicipio(estudiantes:estudiantes_minoritarios, municipio:),
    TotalEstudiantesMunicipio(estudiantes:total,  municipio:),
    estudiantes_minoritarios >= 10,
    Colegio(codigo_colegio:, nombre_municipio:municipio),
    EstudiantesMinoritariosColegio(estudiantes:estudiantes_minoritarios_colegio, codigo_colegio:),
    TotalEstudiantesColegio(estudiantes:total_estudiantes_colegio, codigo_colegio:),
    SegregacionDesagregada(valor_segregacion:segregacion_colegio, minoritarios_n:estudiantes_minoritarios_colegio, minoritarios:estudiantes_minoritarios, total_n:total_estudiantes_colegio, total:);

#@OrderBy(SegregacionMunicipal, "valor_segregacion");
SegregacionMunicipal(valor_segregacion:, codigo_colegio:, nombre_colegio:,
    municipio:, estudiantes_minoritarios_colegio:, total_estudiantes_colegio:) :-
    Colegio(codigo_colegio:, nombre_colegio:, nombre_municipio:municipio),
    EstudiantesMinoritariosColegio(estudiantes:estudiantes_minoritarios_colegio, codigo_colegio:),
    EstudiantesMinoritariosMunicipio(estudiantes:estudiantes_minoritarios_municipio, municipio:),
    TotalEstudiantesColegio(estudiantes:total_estudiantes_colegio, codigo_colegio:),
    TotalEstudiantesMunicipio(estudiantes:total_estudiantes_municipio, municipio:),
    estudiantes_minoritarios_municipio >= 10,
    SegregacionDesagregada(valor_segregacion:,
        minoritarios_n:estudiantes_minoritarios_colegio,
        minoritarios:estudiantes_minoritarios_municipio,
        total_n:total_estudiantes_colegio,
        total:total_estudiantes_municipio);