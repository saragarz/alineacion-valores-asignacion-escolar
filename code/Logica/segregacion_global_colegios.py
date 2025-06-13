import duckdb
from logica.common import logica_lib
from pyproj import Transformer
import folium
import matplotlib
from matplotlib import colors

ruta_bd = "../../data/database/madrid.duckdb"
conexion = duckdb.connect(ruta_bd)

def obtener_lat_lon_colegio(codigo_colegio, coordenadas_colegios):
    coordenadas_colegio = coordenadas_colegios.loc[coordenadas_colegios['codigo_colegio'] == codigo_colegio]
    if coordenadas_colegio.empty:
        return None, None
    else:
        transformador = Transformer.from_crs("EPSG:25830", "EPSG:4326", always_xy=True)
        lon, lat = transformador.transform(coordenadas_colegio.iloc[0]['x'], coordenadas_colegio.iloc[0]['y'])
        return lat, lon

def marcador_circulo(lat, lon, radio, color, color_relleno, popup):
    marcador = folium.CircleMarker(
        location=[lat, lon],
        radius=radio,
        color=color,
        weight=1,
        fill=True,
        fill_color=color_relleno,
        fill_opacity=0.7,
        popup=popup
    )
    return marcador

def marcador_segregacion_colegio(segregacion_colegio, min_segregacion, max_segregacion, coordenadas_colegios):
    codigo = segregacion_colegio['codigo_colegio']
    nombre = segregacion_colegio['nombre_colegio']
    segregacion = segregacion_colegio['valor_segregacion']
    estudiantes_minoria = segregacion_colegio['estudiantes_minoritarios_colegio']
    total_estudiantes = segregacion_colegio['total_estudiantes_colegio']
    lat, lon = obtener_lat_lon_colegio(codigo, coordenadas_colegios)
    popup = (f"{nombre}<br>"
             f"Valor de segregación = {segregacion}<br>"
             f"Alumnos de renta mínima: {int(estudiantes_minoria)}<br>"
             f"Total de alumnos: {int(total_estudiantes)}<br>")
    if lat != None and lon != None:
        radio_min = 4
        radio_max = 12
        if segregacion > 0:
            radio = radio_min + (segregacion / max_segregacion) * (radio_max - radio_min)
            color = colors.to_hex(matplotlib.colormaps['Reds'](segregacion / max_segregacion))
            return marcador_circulo(lat, lon, radio, 'red', color, popup)
        elif segregacion < 0:
            radio = radio_min + (segregacion / min_segregacion) * (radio_max - radio_min)
            color = colors.to_hex(matplotlib.colormaps['Blues'](segregacion / min_segregacion))
            return marcador_circulo(lat, lon, radio, 'blue', color, popup)
        else:
            return marcador_circulo(lat, lon, radio_min, 'white', 'white', popup)
    else:
        return None

mapa = folium.Map(location=[40.4168, -3.7038], zoom_start=9)
segregacion_colegios = logica_lib.RunPredicateToPandas('segregacion.l',
                                                       'SegregacionColegioCAM', connection=conexion)
coordenadas_colegios = logica_lib.RunPredicateToPandas('segregacion.l',
                                                       'CoordenadasColegio', connection=conexion)
max_segregacion = max(segregacion_colegios['valor_segregacion'])
min_segregacion = min(segregacion_colegios['valor_segregacion'])
cont = 0
for _, segregacion_colegio in segregacion_colegios.iterrows():
    marcador_segregacion_colegio(segregacion_colegio, min_segregacion, max_segregacion, coordenadas_colegios).add_to(mapa)
    cont += 1
    print(cont)

mapa.save(f"../../maps/segregacion_global_colegios.html")

conexion.close()