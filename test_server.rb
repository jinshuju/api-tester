require 'sinatra'
require "sinatra/streaming"

set connections: [], loggin: true, bind: '0.0.0.0'

get '/stream', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.connections << out
    out.callback { settings.connections.delete(out) }
  end
end

get "/" do
  erb :index
end

post "/" do
  settings.connections.each { |out| out << "data: #{request.body.string}\n\n" }
  204
end

__END__

@@ index
<html>
  <head>
    <title>jinshuju server</title>
    <meta charset="utf-8">
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script> 
    <style>
    textarea { width: 308px;
height: 400px;
font-size: 12px;
font-family: monospace;
border: 0px;
background-color: #eee;
margin: 10px;
padding: 10px;;}
    </style>
  </head>

  <body>
    <h1>Jinshuju Server</h1>
    <div id="data"></div>
    <script>
     $(function(){
        var es = new EventSource("/stream")
        es.onmessage = function(e) {
          json = JSON.parse(e.data)
          id = (new Date()).getTime()
          json_str = JSON.stringify(json, undefined, 2)
          json_str = "<textarea id='"+id+"'>" + json_str + "</textarea>"
          $("#data").prepend(json_str);
        }
      })
    </script>
  </body>

</html>