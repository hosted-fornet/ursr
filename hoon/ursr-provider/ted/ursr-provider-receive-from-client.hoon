/-  spider, ursr
/+  *strandio, ursr-lib=ursr
=,  strand=strand:spider
^-  thread:spider
|=  args-vase=vase
=/  m  (strand ,vase)
^-  form:m
::
%-  (slog leaf+"ursr-prfc: provider receive from client thread started" ~)
=/  args=args-provider-to-provider:ursr  !<(args-provider-to-provider:ursr args-vase)
=/  client-path=path  /client-to-provider
::
::  Receive subscription from Urth,
::
;<  urth-path=path  bind:m  take-watch
%-  (slog leaf+"ursr-prfc: got watch from {<urth-path>}" ~)
::  Subscribe to client app, which will send audio.
::
;<  ~               bind:m  (watch /from-client [client.args %ursr-client] client-path)
::  Pass through Engine reply facts from Urth to client.
::
;<  ~               bind:m  (pass-fact-through:ursr-lib /from-client urth-path)
::  Clean up.
::
;<  ~               bind:m  (take-kick /from-client)
::
(pure:m !>(~))