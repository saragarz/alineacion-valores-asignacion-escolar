import duckdb
from logica.common import logica_lib
import folium
import matplotlib
from matplotlib import colors
from shapely import wkb
import geopandas

ruta_bd = "../../data/database/madrid.duckdb"
conexion = duckdb.connect(ruta_bd)

def estilo_poligono(segregacion, min_segregacion, max_segregacion):
    epsilon = 1e-5
    norm_pos = colors.Normalize(vmin=epsilon, vmax=max_segregacion)
    norm_neg = colors.Normalize(vmin=epsilon, vmax=abs(min_segregacion))
    if segregacion > 0:
        color = colors.to_hex(matplotlib.colormaps['Reds'](norm_pos(segregacion)))
    elif segregacion < 0:
        color = colors.to_hex(matplotlib.colormaps['Blues'](norm_neg(abs(segregacion))))
    else:
        color = 'white'
    return {
        'fillColor': color,
        'color': 'black',
        'weight': 1,
        'fillOpacity': 0.7
    }


def poligono_municipio(municipio, min_segregacion, max_segregacion, poligonos):
    poligono = poligonos[poligonos['municipio'] == municipio['municipio']]

    if not poligono.empty:
        gdf = geopandas.GeoDataFrame([{
            'municipio': municipio['municipio'],
            'valor_segregacion': municipio['valor_segregacion'],
            'estudiantes_minoritarios_municipio': municipio['estudiantes_minoritarios_municipio'],
            'total_estudiantes_municipio': municipio['total_estudiantes_municipio'],
            'geometry': poligono.iloc[0]['geometry']
        }], geometry='geometry')
        gdf['geometry'] = gdf['geometry'].simplify(tolerance=0.001)

        return folium.GeoJson(
            gdf.to_json(),
            name=str(municipio['municipio']),
            tooltip=folium.GeoJsonTooltip(
                fields=['municipio', 'valor_segregacion',
                        'estudiantes_minoritarios_municipio', 'total_estudiantes_municipio'],
                aliases=['Municipio', 'Valor de segregación', 'Alumnos de renta mínima', 'Total de alumnos']
            ),
            style=estilo_poligono(municipio['valor_segregacion'], min_segregacion, max_segregacion)
        )
    else:
        print(f"No se encontró geometría para {municipio['municipio']}")
        return None

municipios = logica_lib.RunPredicateToPandas('segregacion.l',
                                             'SegregacionMunicipioCAM',
                                             connection=conexion)
poligonos = logica_lib.RunPredicateToPandas('segregacion.l',
                                            'PoligonoMunicipio',
                                            connection=conexion)

poligonos['geometry'] = poligonos['poligono'].apply(lambda b: wkb.loads(bytes(b)))


mapa = folium.Map(location=[40.4168, -3.7038], zoom_start=9)

max_segregacion = max(municipios['valor_segregacion'])
min_segregacion = min(municipios['valor_segregacion'])
cont = 0


for _, municipio in municipios.iterrows():
    p = poligono_municipio(municipio, min_segregacion, max_segregacion, poligonos)
    if p is not None:
        p.add_to(mapa)
    cont += 1
    print(cont)


mapa.save(f"../../maps/segregacion_global_municipios.html")


conexion.close()