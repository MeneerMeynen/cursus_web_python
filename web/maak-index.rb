# Maakt web/index.html: een overzicht van alle hoofdstukken en hun onderdelen.
#
# De volgorde van de hoofdstukken komt uit de include::-regels in cursus-volledig.adoc.
# Gebruik: ruby web/maak-index.rb

require 'asciidoctor'
require 'cgi'

MAP = __dir__
PROJECTEN = ['spaceinvaders.adoc']

def hoofdstukken
  File.readlines(File.join(MAP, 'cursus-volledig.adoc'))
      .map { |regel| regel[/^include::(.+\.adoc)\[\]/, 1] }
      .compact
end

def onderdelen(bestand)
  doc = Asciidoctor.load_file(File.join(MAP, bestand), safe: :safe, parse_header_only: false)
  secties = doc.sections.map { |sectie| [sectie.title, sectie.id] }
  [doc.doctitle, secties]
end

def blok(nummer, bestand)
  titel, secties = onderdelen(bestand)
  pagina = bestand.sub(/\.adoc\z/, '.html')
  prefix = nummer ? "#{nummer}. " : ''
  items = secties.each_with_index.map do |(sectie, id), i|
    nr = nummer ? "#{nummer}.#{i + 1} " : ''
    %(        <li><a href="#{pagina}##{id}">#{nr}#{sectie}</a></li>)
  end
  <<~HTML
    <details class="hoofdstuk">
      <summary><a href="#{pagina}">#{prefix}#{titel}</a></summary>
      <ul>
#{items.join("\n")}
      </ul>
    </details>
  HTML
end

lijst = hoofdstukken.each_with_index.map { |bestand, i| blok(i + 1, bestand) }.join
projecten = PROJECTEN.map { |bestand| blok(nil, bestand) }.join

html = <<~HTML
  <!DOCTYPE html>
  <html lang="nl">
  <head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Cursus Webdesign</title>
  <!-- Gegenereerd door maak-index.rb. Pas dit bestand niet met de hand aan. -->
  <style>
  @import url('https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap');

  body {
    font-family: 'Roboto', sans-serif;
    color: #393838;
    margin: 0;
    padding: 0 16px 40px;
  }

  main {
    max-width: 800px;
    margin: 0 auto;
  }

  h1 {
    font-size: 2em;
    text-align: center;
    padding: 0.5em 0 0.2em;
    margin: 0;
  }

  .ondertitel {
    text-align: center;
    color: grey;
    margin-top: 0;
  }

  h2 {
    border-bottom: 1px solid #ddd;
    padding-bottom: 4px;
    margin-top: 32px;
  }

  a {
    color: #1565c0;
    text-decoration: none;
  }

  a:hover {
    text-decoration: underline;
  }

  .hoofdstuk {
    border: 1px solid #ddd;
    border-radius: 8px;
    margin: 8px 0;
    padding: 10px 14px;
  }

  .hoofdstuk summary {
    cursor: pointer;
    font-weight: bold;
    font-size: 1.1em;
  }

  .hoofdstuk ul {
    list-style: none;
    padding-left: 18px;
    margin: 8px 0 0;
  }

  .hoofdstuk li {
    padding: 3px 0;
  }

  .knoppen {
    text-align: right;
    font-size: 0.9em;
  }

  .knoppen button {
    font: inherit;
    background: none;
    border: none;
    color: #1565c0;
    cursor: pointer;
  }
  </style>
  </head>
  <body>
  <main>
    <h1>Cursus Webdesign</h1>
    <p class="ondertitel">HTML, CSS, Bootstrap, JavaScript en meer</p>

    <h2>Hoofdstukken</h2>
    <div class="knoppen">
      <button type="button" onclick="document.querySelectorAll('details').forEach(d => d.open = true)">Alles openklappen</button> |
      <button type="button" onclick="document.querySelectorAll('details').forEach(d => d.open = false)">Alles dichtklappen</button>
    </div>
  #{lijst}
    <h2>Projecten</h2>
  #{projecten}
    <p><a href="../python/index.html">&#8592; Naar de Python-cursus</a></p>
  </main>
  </body>
  </html>
HTML

File.write(File.join(MAP, 'index.html'), html)
puts "web/index.html gemaakt met #{hoofdstukken.size} hoofdstukken en #{PROJECTEN.size} project(en)."
