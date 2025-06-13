import duckdb
import pandas
import unicodedata
import geopandas

def reformat_name(name):
    if isinstance(name, str) and "," in name:
        parts = [p.strip() for p in name.split(",")]
        return f"{parts[1]} {parts[0]}"
    return name

def clean_text(value):
    if isinstance(value, str):
        value = value.strip()
        value = unicodedata.normalize("NFKC", value)
        value = " ".join(value.split())
        return value
    return value

db_path = "../../data/database/madrid.duckdb"
connection = duckdb.connect(db_path)

solicitudes_path = '../../data/CSV/MadridApplications.csv'
colegios_path = '../../data/CSV/MadridSchools.csv'
municipios_path = "../../data/raw/municipal_polygons_etrs89.geojson"

tables = connection.execute("SHOW TABLES").fetchall()
table_names = [t[0] for t in tables]

if 'Solicitud' not in table_names:
    applications = pandas.read_csv(solicitudes_path, sep=";", encoding="utf-8")
    applications['curso'] = applications['curso'].apply(clean_text)
    print(applications.head(3))
    connection.register('temp_applications', applications)
    connection.execute("""
        CREATE TABLE Solicitud AS 
        SELECT * FROM temp_applications
    """)
    connection.commit()
    print(f"Solicitud saved in {db_path}")

if 'Colegio' not in table_names:
    schools = pandas.read_csv(colegios_path, sep=";", encoding="utf-8")
    schools["nombre_municipio"] = schools["nombre_municipio"].apply(reformat_name)
    print(schools.head(3))
    connection.register('temp_schools', schools)
    connection.execute("""
        CREATE TABLE Colegio AS 
        SELECT * FROM temp_schools
    """)
    connection.commit()
    print(f"Colegio saved in {db_path}")


if 'GeometriaMunicipio' not in table_names:
    municipalities = geopandas.read_file(municipios_path)
    madrid_municipalities = municipalities[municipalities["CODNUT3"] == "ES300"]
    madrid_municipalities = madrid_municipalities[["NAMEUNIT", "geometry"]]
    print(madrid_municipalities.head(3))
    madrid_municipalities["geometry"] = madrid_municipalities["geometry"].apply(lambda g: g.wkb)
    connection.execute("INSTALL spatial;")
    connection.execute("LOAD spatial;")
    connection.register("temp_geometry_municipality", madrid_municipalities)
    connection.execute("CREATE TABLE GeometriaMunicipio AS SELECT * FROM temp_geometry_municipality;")
    connection.commit()
    print(f"GeometriaMunicipio saved in {db_path}")

connection.close()
