<script context="module">
	import { browser, dev } from "$app/env";

	export const hydrate = dev;

	export const router = browser;

	export const prerender = true;
	export const ssr = false;
</script>

<svelte:head>
	<script
		src="https://cdn.jsdelivr.net/npm/@tensorflow/tfjs/dist/tf.min.js"
		type="text/javascript"></script>
	<script
		src="https://cdn.jsdelivr.net/npm/@tensorflow-models/coco-ssd"></script>
	<title>About</title>
</svelte:head>

<script>
	import { onMount } from "svelte";
	let video;
	let liveView;
	let demosSection;
	let enableWebcamButton;
	onMount(() => {
		let frame;
		video = document.getElementById("webcam");
		liveView = document.getElementById("liveView");
		demosSection = document.getElementById("demos");
		enableWebcamButton = document.getElementById("webcamButton");
		function getUserMediaSupported() {
			return !!(
				navigator.mediaDevices && navigator.mediaDevices.getUserMedia
			);
		}
		if (getUserMediaSupported()) {
			enableWebcamButton.addEventListener("click", enableCam);
		} else {
			console.warn("getUserMedia() is not supported by your browser");
		}
		cocoSsd.load().then(function (loadedModel) {
			console.log("cocoSsd", cocoSsd);
			model = loadedModel;
			demosSection.classList.remove("invisible");
		});
		function enableCam(event) {
			if (!model) {
				return;
			}
			event.target.classList.add("removed");
			const constraints = {
				video: true,
			};
			navigator.mediaDevices
				.getUserMedia(constraints)
				.then(function (stream) {
					video.srcObject = stream;
					video.addEventListener("loadeddata", predictWebcam);
				});
		}
		var model = undefined;
		var children = [];
		function predictWebcam() {
			model.detect(video).then(function (predictions) {
				frame = requestAnimationFrame(predictWebcam);
				for (let i = 0; i < children.length; i++) {
					liveView.removeChild(children[i]);
				}
				children.splice(0);
				for (let n = 0; n < predictions.length; n++) {
					if (predictions[n].score > 0.66) {
						const p = document.createElement("p");
						p.innerText =
							predictions[n].class +
							" - with " +
							Math.round(parseFloat(predictions[n].score) * 100) +
							"% confidence.";
						p.style =
							"margin-left: " +
							predictions[n].bbox[0] +
							"px; margin-top: " +
							(predictions[n].bbox[1] - 10) +
							"px; width: " +
							(predictions[n].bbox[2] - 10) +
							"px; top: 0; left: 0;";

						const highlighter = document.createElement("div");
						highlighter.setAttribute("class", "highlighter");
						highlighter.style =
							"left: " +
							predictions[n].bbox[0] +
							"px; top: " +
							predictions[n].bbox[1] +
							"px; width: " +
							predictions[n].bbox[2] +
							"px; height: " +
							predictions[n].bbox[3] +
							"px;";

						liveView.appendChild(highlighter);
						liveView.appendChild(p);
						children.push(highlighter);
						children.push(p);
					}
				}
			});
		}
		return () => cancelAnimationFrame(frame);
	});
</script>

<div class="content">
	<h1>Tensorvision</h1>
	<section id="demos" class="invisible">
		<p>
			Hold some objects up close to your webcam to get a real-time
			classification! When ready click "enable webcam" below and accept
			access to the webcam when the browser asks (check the top left of
			your window)
		</p>

		<div id="liveView" class="camView">
			<button id="webcamButton">Enable Webcam</button>
			<video id="webcam" autoplay muted width="640" height="480" />
		</div>
	</section>
</div>

<style>
	.content {
		width: 100%;
		max-width: var(--column-width);
		margin: var(--column-margin-top) auto 0 auto;
	}
	body {
		font-family: helvetica, arial, sans-serif;
		margin: 2em;
		color: #3d3d3d;
	}

	h1 {
		font-style: italic;
		color: #ff6f00;
	}

	video {
		display: block;
	}

	section {
		opacity: 1;
		transition: opacity 500ms ease-in-out;
	}
	.removed {
		display: none;
	}

	.invisible {
		opacity: 0.2;
	}

	.camView {
		position: relative;
		float: left;
		width: calc(100% - 20px);
		margin: 10px;
		cursor: pointer;
	}

	:global(.camView p) {
		position: absolute;
		padding: 5px;
		background-color: rgba(255, 111, 0, 0.85);
		color: #fff;
		border: 1px dashed rgba(255, 255, 255, 0.7);
		z-index: 2;
		font-size: 12px;
	}

	:global(.highlighter) {
		background: rgba(0, 255, 0, 0.25);
		border: 1px dashed #fff;
		z-index: 1;
		position: absolute;
	}
</style>
