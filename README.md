# UrSR: Urbit Speech Recognition

For some applications, speech is far more natural than text.
UrSR aims to enable calm computing with the power of voice.
It consists of a Gall app and a Golang middleman, and leverages the [Mod9 ASR Engine](https://mod9.io/) to make ASR as simple as a poke.

WARNING: This is ALPHA software.
It shouldn't brick your ship, but I would STRONGLY advise you to run this on a moon.
You can find instructions on how to boot a moon [here](https://urbit.org/using/os/basics#moons).


# Usage

## UrSR Demo Notebook usage example

To use the UrSR Demo Notbook voice notes app, you will need a machine with a mic and to:

1. Know an UrSR provider (currently `~hoster-hosted-labweb` is running a provider node).
1. Get the UrSR Client (which knows how to talk to the provider).
1. Get the UrSR Demo Notebook voice notes app (which is an *aesthetic* JS frontend).

ON A MOON, install the UrSR Client and UrSR Demo Notebook apps:

```
:: Add my software distribution ship as a developer.
:treaty|ally ~dister-hosted-labweb
```

Then, in Grid, search for `~dister-hosted-labweb` and click to install BOTH UrSR Client and UrSR Demo Notebook.
The UrSR Client will run a Gall app that communicates with your UrSR Provider of choice, while the Demo Notebook is an example of a frontend webapp that can take advantage of ASR.

(Alternative install method: `|install ~dister-hosted-labweb %ursr-client`).

For best experience, create a group on your ship and a `Chat` channel within that group: the UrSR Demo Notebook will post transcripts to a chat.

Then, open the UrSR Demo Notebook app by clicking the tile in Grid.

For the `Provider` field, fill in

```
~hoster-hosted-labweb
```

which is my UrSR Provider ship.
You will need to enter your `+code` (another good reason to do this ON A MOON) so the JS webapp can talk to your ship.
And finally, write in the `Chat` channel name you created a moment ago.
Look in the URL when you are in the `Chat` channel in order to get ghe chat name and place ONLY the chat name in this field.
For example, if your URL when you are in the `Chat` channel is

```
http://localhost:8081/apps/landscape/~landscape/ship/~nec/abcdefg/resource/chat/ship/~nec/my-voice-362
```

then you should put

```
my-voice-362
```

into the `Chat` field in the UrSR Demo Notebook webapp.
The `Chat` MUST be hosted on your ship to work!


## Provider set up

It is my intention to make provider set up easier, but until then, here is a guide.

A provider needs to set up three things:

1. The UrSR Provider Gall app on the provider ship.
1. The Mod9 ASR Engine, a TCP server that will do the actual transcription.
1. A Golang middleman that communicates between the UrSR Provider Gall app and the Mod9 ASR Engine.

### UrSR Provider Gall app

On your provider ship (recommended to be a moon!) install the UrSR Provider Gall app from my distribution ship `~dister-hosted-labweb`.
See [UrSR Demo usage](#ursr-demo-notebook-usage-example) above for instructions on how to install.

## Mod9 ASR Engine
I recommend installing the Docker image of the Engine.
To do so, make sure you have installed Docker and then run

```
docker pull mod9/asr
```

To run the Engine, use
```
docker run -p 9900:9900 mod9/asr engine
```

An important caveat related to the Engine: the Engine is not free or open source software.
The copy pulled down from Docker, above, is a 45-day trial.
Instructions on getting a licensed copy will appear here shortly.

To run the trial Engine without CPU throttling, start it as follows:

```
docker run -p 9900:9900 mod9/asr engine --accept-license=yes
```

For more information, please consult the [Engine documentation](https://mod9.io/).

### Golang middleman
The Golang middleman communicates between your provider ship and the Engine.
In the future, it will be distributed as an exectuable.
Until then, you will need to run the source.

First, install Golang following [the docs on the Golang website](https://golang.org/doc/install).

```bash
# Pull the UrSR source code.
git pull https://github.com/hosted-fornet/ursr.git

# Navigate to the UrSR `go` directory.
cd /path/to/ursr/go

# View usage information.
go run cmd/main.go -h

# Run the Golang wrapper with the proper flags for your set up
#  (examples for a fakeship `~wes` below):
go run -code lapwen-fadtun-lagsyl-fadpex -engine localhost:9900 -ship localhost:8080 -ttl 0
```


# Useful `@p`s to know

```
~hosted-fornet          :: me
~hosted-labweb          :: also me
~dister-hosted-labweb   :: my software distribution ship
~hoster-hosted-labweb   :: my UrSR Provider ship
~wisdem-hosted-labweb   :: my group hosting ship
```


# Questions and Feedback

Hit me up at `~hosted-fornet` or come chat in

```
~wisdem-hosted-labweb/homunculus
```


# Privacy notice

Since you are sending your audio to a provider to transcribe, you should not send sensitive audio to people you don't trust.
There is nothing stopping a sketchy provider from keeping your audio and your transcripts.
If you have sensitive audio you wish to transcribe, you should set up your own provider node and use that.


# Dev stuff

## Project structure

UrSR uses a client-provider model, similar to the Urbit Bitcoin app.
Providers will need more technical skills: in addition to running a Gall app, they will need to run the Mod9 ASR Engine which transcribes the audio sent by clients and a Golang middleman that mediates between the Provider Gall app and the Engine.

In contrast, a client need only install the UrSR Client Gall app and whatever application makes use of it.
As an example, this repo includes the UrSR Demo Notebook, a simple JS voice notetaking application.
With it, users can record from the mic on their computer to a Chat channel hosted on their ship.

The UrSR Client and Provider are distributed using standard app distribution from my distribution ship `~dister-hosted-labweb`.
These Gall apps have no frontend: they just talk to each other (and, in the case of the Client, to frontend or other Gall apps).

The repository is structured as follows:
* `go/` contains the Golang middleman that mediates between the transcription Engine and the Provider Gall app,
* `hoon/` contains four directories, three of which are distributed as Gall apps:
    * `ursr-client/` contains the UrSR Client,
    * `ursr-demo/` contains the UrSR Demo Notebook,
    * `ursr-dev/` contains the types and marks devs will need to develop their own frontends for UrSR,
    * `ursr-provider/` contains the UrSR Provider,
* `scripts/` is useful for devs who wish to build the Gall apps in this repo.


## Protocol

### Starting a job

To start a transcription job, poke the UrSR Client running on your ship.
The poke type is `ursr-payload`, which includes a `job-id=@ud`, and an `action`, here, `action=[%client-start-job =options provider=@p]`.
The `job-id` is an `@ud` and *must be unique* to your job: recommended practice is to use a large random number for each job.
The `provider` is a ship running the UrSR Provider Gall app to which your audio data will be sent for transcription.
The `options` are settings for the transcription: documentation of these options can be found at [mod9.io](https://mod9.io).
A recommended, basic set of options is

```json
{
    "command": "recognize",
    "format": "raw",
    "encoding": "pcm_s16le",
    "rate": 16000,
    "transcript-formatted": true
}
```
for audio streamed from a microphone at 16kHz.
16kHz audio is recommended for use with the default transcription model used by the Engine: other rates will be resampled internally.

### Subscribing for replies

The UrSR Client will relay audio to the Provider and relay replies back to the caller.
To receive these replies, subscribe to the UrSR Client at the path `/frontend-path/[job-id]`, with the same job ID used to start the job.
Note that the `job-id` here must be formatted in the Urbit pretty-printed manner, so that, e.g., `1000000` is rendered as `1.000.000`.

Replies are `ursr-payload`-type, with `action` either `relay-reply` or `job-done`.
`job-done`, as indicated by the name, means the transcription has finished.
`relay-reply` contains some of the fields the Engine replies with, including `final`, `result-index`, `transcript`, and, if the `transcript-formatted` option is set to `true`, `transcript-formatted`.

### Sending audio

Audio is `poke`d to the UrSR Client using the `ursr-payload` type.
In addition to the `job-id`, the `action` passed should be `relay-audio`, with field `audio`, an `int16` array (for `encoding: pcm_s16le` `option` field).


# Acknowledgements

You can find the grant proposal for this project
[here](https://urbit.org/grants/speech-recognition).
