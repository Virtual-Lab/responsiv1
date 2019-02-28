 var client
    $(function() {
      client = new rhizome.Client()

      // `rhizome.start` is the first function that should be called.
      // The function inside is executed once the client managed to connect.
      client.start(function(err) {
        if (err) {
          $('body').html('client failed starting : ' + err)
          throw err
        }

        $('#send').submit(function(event) {
          event.preventDefault()
          var address = $('#address').val()
            , args = $('#args').val()
          if (args.length)
            args = args.split(' ').map(function(arg) { return JSON.parse(arg) })
          else args = []
          client.send(address, args)
        })

        // We want to receive all the messages, so we subscribe to '/'
        client.send('/sys/subscribe', ['/'])
      })

      client.on('message', function(address, args) { 
        $('#received .message').slice(20).remove()
        var message = $('<div class="message"><span class="ad"></span><span class="ar"></span></div>')
          .prependTo('#received')
        message.find('.ad').html(address)
        message.find('.ar').html(args.map(function(arg) { return JSON.stringify(arg) }).join(' '))
      })

      client.on('connected', function() {
        alert('connected!')
      })

      client.on('connection lost', function() {
        alert('connection lost!')
      })

      client.on('server full', function() {
        alert('server is full!')
      })

    })