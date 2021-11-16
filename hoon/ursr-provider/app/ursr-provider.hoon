/-  ursr, wl=whitelist
/+  default-agent, ursr-lib=ursr, wl-lib=whitelist
|%
+$  versioned-state
    $%  state-zero
        state-one
    ==
::
+$  state-zero
    $:  [%0 active=(set @ud)]
    ==
::
+$  state-one
    $:  [%1 active=(set @ud) =whitelist.wl]
    ==
::
+$  card  card:agent:gall
::
--
=|  state-one
=*  state  -
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this      .
      def   ~(. (default-agent this %|) bowl)
      hc    ~(. +> bowl)
  ::
  ++  on-init
    ^-  (quip card _this)
    ~&  >  'ursr-provider: initialized successfully'
    `this(public.whitelist.state %.n, kids.whitelist.state %.n)
  ++  on-save
    ^-  vase
    !>(state)
  ++  on-load
    |=  old-state=vase
    ^-  (quip card _this)
    =/  old  !<(versioned-state old-state)
    |-
    ?-    -.old
        %1
      ~&  >  'ursr-provider: recompiled successfully'
      `this(state old)
      ::
        %0
      =|  =whitelist.wl
      $(old [%1 active.old whitelist(public %.n, kids %.n)])
    ==
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?+    mark  (on-poke:def mark vase)
        %ursr-payload
      ?.  (is-whitelisted:wl-lib src.bowl whitelist.state bowl)
        ~&  >  "ursr-provider: got poke from {<src.bowl>}: not on whitelist"
        `this
      ~&  >>>  !<(payload:ursr vase)
      =^  cards  state
      (handle-payload:hc !<(payload:ursr vase))
      [cards this]
      ::
        %whitelist-command
      ?>  (team:title our.bowl src.bowl)
      =^  cards  whitelist.state
      %:  handle-command:wl-lib
          !<(whitelist-command:wl vase)
          whitelist.state
          [~ /provider-to-client]
          bowl
      ==
      [cards this]
      ::
        %noun
      ?>  (team:title our.bowl src.bowl)
      ?+    q.vase  (on-poke:def mark vase)
          %print-state
        ~&  >  state
        ~&  >>  bowl  `this
        ::
          %print-subs
        ~&  >  &2.bowl  `this
      ==
    ==
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    ?+     path  (on-watch:def path)
        [%provider-to-client @ ~]
      =/  job-id-ta=@ta  -.+.path
      =/  job-id=@ud  (slav %ud job-id-ta)
      ?.  (is-whitelisted:wl-lib src.bowl whitelist.state bowl)
        ~&  >  "ursr-provider: blocked subscription from {<src.bowl>}: not on whitelist"
        :_  this
        :~  [%give %fact ~[/provider-to-client/[job-id-ta]] %ursr-payload !>([job-id %job-done %.n])]
            [%give %kick ~ ~]
        ==
      ~&  >  "ursr-provider: got subscription from client {<src.bowl>}; subscribing back {<job-id-ta>}"
      :_  this(active.state (~(put in active.state) job-id))
      :~  [%pass /from-client/[job-id-ta] %agent [src.bowl %ursr-client] %watch /client-to-provider/[job-id-ta]]
      ==
      ::
        [%urth-path ~]
      ~&  >  "ursr-provider: got subscription from urth backend"  `this
    ==
  ++  on-leave
    |=  =path
    ~&  >  "ursr-provider: got subscription leave request on path {<path>}"  `this
  ++  on-peek   on-peek:def
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?+    wire  (on-agent:def wire sign)
        [%from-client @ ~]
      ?+  -.sign  (on-agent:def wire sign)
          %fact
        =/  p=payload:ursr  !<(payload:ursr q.cage.sign)
        ?.  =(%audio-done -.action.p)
          :_  this
          :~  [%give %fact ~[/urth-path] cage.sign]
          ==
        :_  this(active.state (~(del in active.state) job-id.p))
        :~  [%give %fact ~[/urth-path] cage.sign]
            [%pass /from-client/(scot %ud job-id.p) %agent [src.bowl %ursr-client] %leave ~]
        ==
      ==
    ==
  ++  on-arvo   on-arvo:def
  ++  on-fail   on-fail:def
  --
:: start helper core
|_  bowl=bowl:gall
++  handle-payload
  |=  =payload:ursr
  ^-  (quip card _state)
  ?-    -.action.payload
      %job-done
    :_  state
    :~  [%give %fact ~[/provider-to-client/(scot %ud job-id.payload)] %ursr-payload !>(payload)]
    ==
    ::
      %relay-options
    =/  options=options:ursr  +.action.payload
    ~&  >  "ursr-provider: got %provider-start-job request: {<options>}"
    :_  state
    :~  [%give %fact ~[/urth-path] %ursr-payload !>([job-id.payload %relay-options options])]
    ==
    ::
      %relay-reply
    ~&  >  "ursr-provider: got %relay-reply request: {<+.action.payload>}"
    :_  state
    :~  [%give %fact ~[/provider-to-client/(scot %ud job-id.payload)] %ursr-payload !>(payload)]
    ==
    ::
      %audio-done
    ~&  >>>  "ursr-provider: unexpectedly received %audio-done; ignoring"  `state
    ::
      %client-start-job
    ~&  >>>  "ursr-provider: unexpectedly received %client-start-job; ignoring"  `state
    ::
      %relay-audio
    ~&  >>>  "ursr-provider: unexpectedly received %relay-audio; ignoring"  `state
  ==
--
