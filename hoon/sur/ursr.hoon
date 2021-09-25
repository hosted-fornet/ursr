|%
+$  options
  $:  command=cord
      format=cord
      encoding=cord
      rate=@ud
      transcript-formatted=?
  ==
::
+$  engine-reply
  $:  final=?
      result-index=@ud
      transcript=cord
      transcript-formatted=cord
  ==
::
+$  raw-pcm-ssixteenle-audio
  $:  audio=(list cord)
  ==
::
+$  args-frontend-to-client
  $:  =options
      provider=@p
  ==
::
+$  args-client-to-client
  $:  fe=args-frontend-to-client
      client-tid=@ta
  ==
:: Used for:
:: * Client to provider app (tid is client tid).
:: * Provider app to middleman (tid is provider tid).
::
+$  args-over-network
  $:  =options
      tid=@ta
  ==
::
+$  args-provider-to-provider
  $:  client=@p
      client-tid=@ta
  ==
::
+$  client-action
  $%  [%start-threads =args-frontend-to-client]
      [%send-tid tid=@ta]
      [%relay-audio =raw-pcm-ssixteenle-audio]
      [%audio-done done=?]
  ==
::
+$  provider-action
  $%  [%start-job =args-over-network]
      [%relay-audio =raw-pcm-ssixteenle-audio]
      [%relay-reply =engine-reply]
  ==
--