head.js "scripts/zepto.js", "reveal.js/plugin/markdown/marked.js", "scripts/preso.js", ->
  p = new Preso()
  p.forceCodeLanguage "php"
  #p.addDebugElement()

  Reveal.initialize {
    # Display controls in the bottom right corner
    controls: false

    # Display a presentation progress bar
    progress: true

    # If true; each slide will be pushed to the browser history
    history: true

    # Enable keyboard shortcuts for navigation
    keyboard: true

    # Loops the presentation, defaults to false
    loop: false

    # Flags if mouse wheel navigation should be enabled
    mouseWheel: false

    # Apply a 3D roll to links on hover
    rollingLinks: false

    # UI style
    theme: 'simple' # default/neon

      # Transition style
    transition: 'none' # default/cube/page/concave/linear(2d)
    dependencies: [
      {
        src: 'reveal.js/lib/js/classList.js'
        condition: -> !document.body.classList
      }
      {
        src: 'reveal.js/plugin/highlight/highlight.js'
        async: true
        callback: -> hljs.initHighlightingOnLoad()
      }
      #{src: 'lib/prism.js', async: true, callback: -> Prism.highlightAll()}
      {
        src: 'lib/emojify/emojify.min.js'
        async: true
        callback: ->
          emojify.setConfig {
            #emojify_tag_type: 'img'
            emoticons_enabled: true
            people_enabled: true
            nature_enabled: true
            objects_enabled: true
            places_enabled: true
            symbols_enabled: true
          }
          #emojify.run()
      }
    ]
  }

  Reveal.addEventListener 'slidechanged', ->
    current_slide = $('.present')[0]
    Preso.selectLineRanges current_slide


