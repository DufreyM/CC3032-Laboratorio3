# Cómo SiteLang se parece a Vercel CLI por dentro

Antes de este lab pensaba que herramientas como `vercel deploy` eran básicamente magia:
corrés un comando y en segundos tenés una URL pública. Vale aclarar de entrada que el
compilador que hace esa magia en este laboratorio, SiteLang, no lo escribimos nosotros:
la gramática `SiteLang.g4`, el listener `SiteListener.py`, el `Driver.py` y el Dockerfile
vienen dados como parte del material de esta opción del curso. Lo que sí hicimos fue
ponerlo a correr de verdad, con datos reales y contra las APIs reales de GitHub y Vercel,
y eso terminó enseñando más de lo que esperaba.

Ya con el compilador armado, personalizamos `site.sl` con información real en vez de la
plantilla de ejemplo, generamos los tokens de GitHub y Vercel, y corrimos la imagen
Docker esperando que simplemente funcionara. No fue así la primera vez: el contenedor
leía `site.sl` en ASCII, y en cuanto el archivo tuvo una tilde (mi nombre lleva una) el
programa se cayó con un error de encoding. Hubo que agregar `encoding='utf-8'` a la
llamada de `FileStream` en `Driver.py` para que lo aceptara. Después el token de GitHub
que había generado resultó ser de tipo fine-grained, y la API de creación de
repositorios lo rechazaba con un 403 hasta que generé uno clásico con el scope `repo`. Y
ya con el sitio desplegado, Vercel seguía pidiendo login en la URL pública porque los
proyectos nuevos traen activada por defecto la protección de deployment, así que también
hubo que desactivarla desde el dashboard antes de que la URL quedara realmente pública.
Ninguno de esos tres problemas tiene que ver con ANTLR ni con la gramática, los tres
pasan en la capa de integración con las APIs externas, que es justo la parte que uno no
ve hasta que corre el proyecto contra servicios reales en vez de contra un ejemplo que ya
sabemos que va a funcionar.

Ese proceso de arreglar cosas es, sin buscarlo, la mejor forma de entender por qué
`vercel deploy` está diseñado como está. El flujo que sigue SiteLang es el mismo de
cualquier compilador que vimos en el curso: se lee un archivo fuente, se tokeniza, se
arma el árbol sintáctico, se recorre ese árbol y al final se genera algo. La diferencia
está en qué es ese algo generado. En un compilador de un lenguaje de programación
tradicional sería assembly o bytecode; acá son llamadas HTTP. `site.sl` cumple el mismo
rol que cumple `vercel.json` en la herramienta real: describe qué se quiere desplegar sin
decir cómo hacerlo paso a paso, con una gramática que en el fondo describe bloques
anidados (`site` contiene `page`, `page` contiene atributos) del mismo modo estructural
en que lo haría un JSON, solo que expresada a mano con ANTLR en vez de con un parser
genérico. El lexer y el parser que ANTLR genera a partir de esa gramática tokenizan y
validan `site.sl` igual que el CLI de Vercel parsea su configuración antes de hacer
cualquier otra cosa, y el listener recorre ese árbol acumulando la información en
variables de Python, que es básicamente el análisis semántico del compilador: juntar
datos que están dispersos por el árbol en una sola estructura que después se pueda usar.

La parte que más me hizo click fue el método `deploy()` del listener, porque ahí se ve
clarísimo que la fase de generación de código de este compilador no termina en un
archivo, sigue hasta una API:

```python
def deploy(self):
    html = self._generate_html()
    full_name, repo_name = self._create_github_repo()
    self._push_to_github(full_name, html)
    self._deploy_to_vercel(repo_name, html)
```

Primero genera el HTML, eso es generación de código en el sentido de siempre. Después
vienen tres llamadas que emiten efectos hacia afuera del programa: crea el repositorio,
sube el archivo, dispara el deploy. Es literalmente lo que hace `vercel deploy` cuando lo
corrés desde tu computadora, arma un payload con los archivos del proyecto y lo manda al
mismo endpoint que se usa acá directamente, `POST /v13/deployments`. La diferencia es que
el CLI real lo hace con muchísimo más cuidado que este compilador de un lab: reintentos
si falla la red, subida en partes cuando el proyecto pesa más, detección automática de
framework, variables de entorno remotas, caché de builds anteriores para no repetir
trabajo. Lo que hay en `SiteListener.py` es la versión mínima de exactamente esas mismas
llamadas, sin nada de esa capa de robustez, y quizás por eso mismo se entiende más fácil.

Al final, lo que este lab deja ver es que Vercel CLI no es magia ni un caso especial de
ingeniería, es un compilador donde el destino final de la generación de código es una API
HTTP en vez de una arquitectura de instrucciones. El mismo patrón de lexer, parser,
listener y generación de código que usamos para construir un lenguaje de programación en
este curso sirve igual para construir una herramienta de despliegue, solo cambia qué se
considera el código objeto al final del camino. Y curiosamente, lo que más ayudó a verlo
no fue leer el código ya armado del listener, sino los tres errores que salieron al
correrlo con datos reales.
