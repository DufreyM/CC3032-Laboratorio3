# Define tu sitio aquí.
# Al correr el compilador se genera el HTML, se crea el repo en GitHub y se despliega a Vercel.
# TODO: reemplaza estos valores de ejemplo con los tuyos antes de correr el compilador.

site "mi-sitio-cc3032" {
  title       = "TU NOMBRE — UVG 2026"
  description = "Estudiante de CS construyendo compiladores en la Universidad del Valle de Guatemala"
  theme       = "dark"

  page "index" {
    hero    = "Hola, construí este sitio con un compilador que yo escribí"
    about   = "Soy estudiante de CS en la UVG. Esta página fue generada a partir de un DSL propio, subida a GitHub y desplegada en Vercel — todo por mi compilador hecho con ANTLR."
    contact = "tu.correo@example.com"
  }
}
