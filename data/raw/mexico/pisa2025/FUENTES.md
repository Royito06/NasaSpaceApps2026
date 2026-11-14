# Fuentes de PISA 2025 (OCDE) descargadas el 14-nov-2026

Los dos PDF se bajaron del sitio de la OCDE con `curl` desde Ramona y después se copiaron aquí. Las huellas SHA-256 están en `SHA256SUMS`. La carpeta `txt/` trae el texto de cada PDF sacado con `pdftotext -layout`; no son originales.

Las páginas web de la OCDE (`www.oecd.org/en/publications/...`) piden una verificación de navegador y no se pueden bajar con `curl`. Los PDF, que están bajo `www.oecd.org/content/dam/`, sí.

| Archivo | Qué es | URL |
|---|---|---|
| `ocde_pisa2025_resultados_volumen_1.pdf` | OCDE. *PISA 2025 Results (Volume I)*. 377 páginas. De la Table I.1 (pp. 28-29) salen las medias de 2025 de México y del promedio OCDE | `https://www.oecd.org/content/dam/oecd/en/publications/reports/2026/09/pisa-2025-results-volume-i_5265bfb1/73451bc5-en.pdf` |
| `ocde_pisa2025_nota_pais_mexico.pdf` | OCDE. *PISA 2025 Results (Volume I) – Country notes: Mexico*. 14 páginas. De las pp. 5-6 salen los porcentajes de estudiantes con nivel 2 o más; las figuras 2 y 3 rotulan la media de México | `https://www.oecd.org/content/dam/oecd/en/publications/reports/2026/09/pisa-2025-results-volume-i-country-notes_88d1164e/mexico_40016e3e/85702d30-en.pdf` |

## Cifras leídas y dónde están

Las cifras están en `eda/tables/mexico_pisa_2025_ocde.csv`, que escribe `eda/04_mexico.py`.

| Cifra | México | Promedio OCDE | Dónde se leyó |
|---|---|---|---|
| Matemáticas, puntaje medio | 388 | 463 | Volumen I, Table I.1, pp. 28-29 |
| Lectura, puntaje medio | 408 | 461 | Volumen I, Table I.1, pp. 28-29 |
| Ciencias, puntaje medio | 414 | 482 | Volumen I, Table I.1, pp. 28-29 |
| Matemáticas, % con nivel 2 o más | 30 | 65 | Nota de país, p. 5 |
| Ciencias, % con nivel 2 o más | 50 | 74 | Nota de país, p. 5 |
| Lectura, % con nivel 2 o más | 50 | 69 | Nota de país, p. 6 |

La misma Table I.1 da el cambio de México entre 2022 y 2025: matemáticas -7 (significativo), lectura -7 y ciencias +4 (no significativos). El -7 de matemáticas coincide con la serie que ya tenía el EDA (395 en 2022).

Las medias se revisaron en el texto del PDF y a la vista en la tabla. En la nota de país las medias sólo aparecen como rótulos dentro de las figuras, no en el texto.
