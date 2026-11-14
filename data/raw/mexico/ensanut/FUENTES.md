# Fuentes de Ensanut (INSP) descargadas el 14-nov-2026

Todos los PDF se bajaron del sitio oficial del INSP (`ensanut.insp.mx`) con `curl` desde Ramona, porque la red de la laptop iba a unos 10 KB/s, y después se copiaron aquí. Las huellas SHA-256 están en `SHA256SUMS` y coinciden con las copias de Ramona.

La carpeta `txt/` no trae originales: es el texto de cada PDF sacado con `pdftotext -layout`, para poder buscar cifras sin abrir el PDF.

Todas las URL empiezan con `https://ensanut.insp.mx/encuestas/`.

## Usadas en `eda/tables/mexico_ensanut.csv`

| Archivo | Qué es | URL (después del prefijo) |
|---|---|---|
| `ensanut2020-2024_17311_sobrepeso_obesidad_escolares_adolescentes_nacional_estatal.pdf` | Shamah-Levy T y col. Prevalencia nacional y estatal de sobrepeso y obesidad en escolares y adolescentes en México y factores asociados. Salud Publica Mex 2025;67(6):609-621. doi:10.21149/17311 | `ensanutcontinua2024/doctos/analiticos/17311-Texto%20del%20art%C3%ADculo-92189-1-10-20251118.pdf` |
| `ensanut2020-2024_17642_resultados_estatales.pdf` | Shamah-Levy T y col. Resultados estatales de la Encuesta Nacional de Salud y Nutrición Continua 2020-2024. Salud Publica Mex 2025;67(supl 1):s3-s219. doi:10.21149/17642. Trae 145 indicadores por estado; la tabla nacional empieza en la p. S22 y la de Sonora ocupa las pp. S178-S183 | `ensanutcontinua2024/doctos/analiticos20-24/17642-Texto%20del%20art%C3%ADculo-92946-2-10-20251219.pdf` |
| `ensanut2018-2024_16955_actividad_fisica_sedentarismo_sueno_adolescentes.pdf` | Medina C y col. Prevalencia y tendencia de actividad física, comportamiento sedentario y sueño en adolescentes. Salud Publica Mex 2025;67(6):562-574. doi:10.21149/16955. Compara Ensanut 2012, 2018 y 2022-2024 | `ensanutcontinua2024/doctos/analiticos/16955-Texto%20del%20art%C3%ADculo-92185-1-10-20251118.pdf` |
| `ensanut2023_15787_promocion_actividad_fisica_escolares_adolescentes.pdf` | Medina C y col. Promoción de actividad física en escolares y adolescentes. Salud Publica Mex 2024;66(4):435-445. doi:10.21149/15787. Datos de Ensanut 2022-2023 | `ensanutcontinua2023/doctos/analiticos/15787-Texto%20del%20art%C3%ADculo-82495-2-10-20240821.pdf` |
| `ensanut2022_14754_comportamientos_del_movimiento.pdf` | Medina C y col. Prevalencia de comportamientos del movimiento en población mexicana. Salud Publica Mex 2023;65(supl 1):S259-S267. doi:10.21149/14754. Datos de Ensanut 2022 | `ensanutcontinua2022/doctos/analiticos/33-Movimiento.en.poblacion-ENSANUT2022-14754-72522-2-10-20230619.pdf` |
| `ensanut2023_informe_resultados_nacionales.pdf` | INSP. Encuesta Nacional de Salud y Nutrición Continua 2023. Resultados Nacionales. Cuernavaca, 2024 (221 páginas) | `ensanutcontinua2023/doctos/informes/ensanut_23_112024.pdf` |
| `ensanut2022_14827_sintomatologia_depresiva_adolescentes_adultos.pdf` | Vázquez-Salas RA y col. Sintomatología depresiva en adolescentes y adultos mexicanos: Ensanut 2022. Salud Publica Mex 2023;65(supl 1):S117-S125. doi:10.21149/14827 | `ensanutcontinua2022/doctos/analiticos/16-Sintomatologia.depresiva-ENSANUT2022-14827-72384-2-10-20230619.pdf` |
| `ensanut2020-2023_15842_sobrepeso_obesidad_escolares_adolescentes.pdf` | Shamah-Levy T y col. Sobrepeso y obesidad en población escolar y adolescente. Salud Publica Mex 2024;66(4):404-413. doi:10.21149/15842. Edición anterior (2020-2023) | `ensanutcontinua2023/doctos/analiticos/15842-Texto%20del%20art%C3%ADculo-82492-3-10-20240822.pdf` |

## Descargadas como apoyo (ninguna cifra del CSV sale de aquí)

| Archivo | Qué es | URL (después del prefijo) |
|---|---|---|
| `ensanut2022_metodologia.pdf` | Romero-Martínez M y col. Metodología de la Ensanut 2022 y planeación y diseño de la Ensanut Continua 2020-2024. Salud Publica Mex 2022;64:522-529. doi:10.21149/14186. De aquí sale qué estados forman cada región (Pacífico-Norte: Baja California, Baja California Sur, Nayarit, Sinaloa y Sonora) | `ensanutcontinua2022/doctos/analiticos/02-Metodologia-ENSANUT2022-65626-2-10-20220830.pdf` |
| `ensanut2020-2024_metodologia.pdf` | Romero-Martínez M y col. Metodología y análisis de la Encuesta Nacional de Salud y Nutrición Continua 2020-2024 | `ensanutcontinua2024/doctos/analiticos20-24/202412-Metodologia-ENSANUT-2020-2024.pdf` |
| `ensanut2024_17250_sintomatologia_depresiva_nicotina_cannabis_alcohol.pdf` | Arillo-Santillán E y col. Sintomatología depresiva y consumo de nicotina, cannabis y alcohol. Salud Publica Mex 2025;67(6):785-794. doi:10.21149/17250. Sólo adultos de 20 años o más, por eso no se usó | `ensanutcontinua2024/doctos/analiticos/17250-Texto%20del%20art%C3%ADculo-92205-1-10-20251118.pdf` |

## Qué se revisó y no dio datos

- **Ensanut Continua 2025.** La página de documentos analíticos de 2025 (`ensanutcontinua2025/documentos_analiticos.php`) sólo lista el artículo de diseño metodológico, y ese enlace devolvió error 404. No hay resultados de 2025 publicados ahí al 14-nov-2026.
- **Un PDF en otro sitio del INSP** (`prevenirelsuicidioadolescente.insp.mx`) no respondió; el mismo artículo se bajó de `ensanut.insp.mx`.

## Cómo volver a bajar un archivo

```bash
curl -L -A 'Mozilla/5.0' -o ARCHIVO.pdf 'https://ensanut.insp.mx/encuestas/RUTA_DE_LA_TABLA'
sha256sum -c SHA256SUMS
```
