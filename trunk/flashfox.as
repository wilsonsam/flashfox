/*
	FlashFox
	Flash HTML5-Style Video Player
	By Jonathan Neal
		for Liferay
			with Love for YayQuery
*/


/* Project Properties */

Stage.align = "LT";
Stage.scaleMode = "noScale";



/* Global Vars */

var connect,
	stream,
	video,
	audio,

	poster_trueWidth,
	poster_trueHeight,

	video_trueWidth,
	video_trueHeight,
	video_position,
	video_percent,
	video_duration,

	is_playing = false,
	is_muted = false,
	is_seeking = false,
	first_hover = false,

	autoplay = _root.autoplay == "true",
	controls_locked = _root.controls == "false",

	controls_visible = _root.controls == "true",
	controls_hover_timeout = 24 * 8,
	controls_override = false,

	duration_text_format,
	duration_minutes = "0",
	duration_seconds = "00",

	fullscreen = new Object(),
	keyboard = new Object();


/* Poster */

this.createEmptyMovieClip("poster_canvas", 0);

var poster_mclListener:Object = new Object();
	poster_mclListener.onLoadInit = function (target_mc:MovieClip) {
		poster_trueWidth = (_root.width) ? _root.width : poster_canvas._width || Stage.width;
		poster_trueHeight =(_root.height) ? _root.height : poster_canvas._height || Stage.height;

		fn_resize_poster();
	};

var poster_mcl = new MovieClipLoader();
	poster_mcl.addListener(poster_mclListener);
	poster_mcl.loadClip(_root.poster, poster_canvas);



/* Function: Resize Poster */

function fn_resize_poster() {
	var poster_scale = Math.min(Stage.width / poster_trueWidth, Stage.height / poster_trueHeight);

	with (poster_canvas) {
		_width = poster_trueWidth * poster_scale;
		_height = poster_trueHeight * poster_scale;
		_x = (Stage.width - (poster_trueWidth * poster_scale)) / 2;
		_y = (Stage.height - (poster_trueHeight * poster_scale)) / 2;
	}
};



/* Video */

this.createEmptyMovieClip("video_canvas", 300);

nc = new NetConnection();
	nc.connect(null);

stream = new NetStream(nc);
stream.setBufferTime(10);

video.attachVideo(stream);

video_canvas.attachAudio(stream);

audio = new Sound(video_canvas);

audio.setVolume(100);

stream.onMetaData = function (args) {
	fadeOut(poster_canvas, 30);

	video_trueWidth = (_root.width) ? _root.width : args.width || Stage.width;
	video_trueHeight = (_root.height) ? _root.height : args.height || Stage.height;

	video_duration = args.duration || 0;

	duration_minutes = Math.floor(video_duration / 60);
	duration_seconds = Math.floor(video_duration - (duration_minutes * 60));
	duration_seconds = (duration_seconds < 10) ? '0' + duration_seconds : duration_seconds;

	duration_text_holder.duration_text.text = duration_minutes + ":" + duration_seconds;
	duration_text_holder.duration_text.setTextFormat(duration_text_format);

	fn_resize_video();
};



/* Function: Resize Video */

function fn_resize_video() {
	var video_scale = Math.min(Stage.width / video_trueWidth, Stage.height / video_trueHeight);

	with (video) {
		_width = video_trueWidth * video_scale;
		_height = video_trueHeight * video_scale;
		_x = (Stage.width - (video_trueWidth * video_scale)) / 2;
		_y = (Stage.height - (video_trueHeight * video_scale)) / 2;
	}
};



/* Function: Draw Controls */

function fn_draw_controls() {
	controls_visible = false;

	/* Controls Background */
	this.createEmptyMovieClip('controls_bg', 20);
	with (controls_bg) {
		_alpha = 0;
		beginFill(0x1A1717);
		moveTo(0, Stage.height - 28);
		lineTo(Stage.width, Stage.height - 28);
		lineTo(Stage.width, Stage.height);
		lineTo(0, Stage.height);
		endFill();
	}

	/* Play Button */
	this.createEmptyMovieClip('play_btn', 21);
	with (play_btn) {
		_alpha = 0;
		_x = 9;
		_y = Stage.height - 20;
		beginFill(0xFFFFFF);
		moveTo(0, 0);
		lineTo(9, 6);
		lineTo(0, 12);
		endFill();
	}

	/* Pause Button */
	this.createEmptyMovieClip('pause_btn', 22);
	with (pause_btn) {
		_alpha = 0;
		_x = 9;
		_y = Stage.height - 20;
		beginFill(0xFFFFFF);
		moveTo(0, 0);
		lineTo(0, 12);
		lineTo(4, 12);
		lineTo(4, 0);
		endFill();
		beginFill(0xFFFFFF);
		moveTo(7, 0);
		lineTo(7, 12);
		lineTo(11, 12);
		lineTo(11, 0);
		endFill();
	}

	/* Duration Bar */
	this.createEmptyMovieClip('duration_bar', 23);
	with (duration_bar) {
		_alpha = 0;
		_x = 32;
		_y = Stage.height - 14;
		lineStyle(8, 0x9c9a9a, 80);
		moveTo(0, 0);
		lineTo(Stage.width - 98, 0);
	}

	/* Progress Bar */
	this.createEmptyMovieClip('progress_bar', 24);
	with (progress_bar) {
		_alpha = 0;
		_x = 32;
		_y = Stage.height - 14;
		lineStyle(8, 0xcac8c8, 80);
		moveTo(0, 0);
		lineTo(7, 0);
	}

	/* Time Slider */
	this.createEmptyMovieClip('time_slider', 25);
	with (time_slider) {
		_alpha = 0;
		_x = 28;
		_y = Stage.height - 23;
		lineStyle(2.5, 0xFFFFFF, 100);
		beginFill(0x474747);
		moveTo(0, 5);
		curveTo(0, 0, 4.5, 0);
		curveTo(9, 0, 9, 5);
		lineTo(9, 13);
		curveTo(9, 18, 4.5, 18);
		curveTo(0, 18, 0, 13);
		lineTo(0, 5);
		endFill();
	}

	/* Volume Button */
	this.createEmptyMovieClip('volume_btn', 26);
	with (volume_btn) {
		_alpha = 0;
		_x = Stage.width - 24;
		_y = Stage.height - 22;
		lineStyle(0, 0xFFFFFF, 100);
		beginFill(0xFFFFFF);
		moveTo(0, 5);
		lineTo(0, 10);
		lineTo(3, 10);
		lineTo(8, 14);
		lineTo(8, 1);
		lineTo(3, 5);
		endFill();
	}

	/* Volume On Button */
	this.createEmptyMovieClip('volume_on_btn', 27);
	with (volume_on_btn) {
		_alpha = 0;
		_x = Stage.width - 12;
		_y = Stage.height - 18;
		lineStyle(3, 0xFFFFFF, 100);
		moveTo(0, 0);
		curveTo(5, 3, 0, 7);
	}

	/* Duration Text */
	this.createEmptyMovieClip('duration_text_holder', 28);

	with (duration_text_holder) {
		_visible = false;
		_x = Stage.width - 56;
		_y = Stage.height - 23;
	}

	duration_text_holder.createTextField("duration_text", 29, 0, 0, 60, 20);

	duration_text_format = new TextFormat();
	duration_text_format.color = 0xCCCCCC;
	duration_text_format.font = "Arial";
	duration_text_format.size = "11";

	duration_text_holder.duration_text.text = duration_minutes + ":" + duration_seconds;
	duration_text_holder.duration_text.setTextFormat(duration_text_format);

	/* Control Canvas */
	this.createEmptyMovieClip('control_canvas', 1000);
	control_canvas.buttonMode = false;
	with (control_canvas) {
		_alpha = 0;
		beginFill(0x000000);
		moveTo(0, 0);
		lineTo(Stage.width, 0);
		lineTo(Stage.width, Stage.height);
		lineTo(0, Stage.height);
		endFill();
	}

	control_canvas.onRollOver = function () {
		is_seeking = false;
		first_hover = true;
	};

	control_canvas.onRollOut = function () {
		controls_hover_timeout = 24;
		is_seeking = false;
	};

	control_canvas.onPress = function () {
		if (_root._ymouse >= Stage.height - 28) {
			is_seeking = true;
		}
	};

	control_canvas.onMouseMove = function () {
		if (is_seeking) {
			/* Seek */
			stream.seek(((_root._xmouse - 28) / duration_bar._width) * video_duration);
		}
		if (!controls_visible) {
			/* Needs Controls */
			fn_controls_visible(36);
		}
		if (_root._ymouse >= (Stage.height - 28)) {
			/* Slow Controls Fadeout when over controls */
			controls_hover_timeout = 24 * 24;
		}
		else {
			/* Set Controls Fadeout normally otherwise */
			controls_hover_timeout = 24 * 12;
		}
	};

	control_canvas.onRelease = function () {
		if (_root._xmouse <= 28 && _root._ymouse >= (Stage.height - 28)) {
			if (!is_playing) {
				/* Play */
				fn_play();
			}
			else {
				/* Pause */
				fn_pause();
			}
		}

		else if (_root._xmouse >= (Stage.width - 28) && _root._xmouse <= (Stage.width - 4) && _root._ymouse >= (Stage.height - 28)) {
			if (!is_muted) {
				/* Mute */
				fn_mute();
			}
			else {
				/* Unmute */
				fn_unmute();
			}
		}

		else if (is_seeking) {
			/* Seek */
			stream.seek(((_root._xmouse - 28) / duration_bar._width) * video_duration);
		}

		is_seeking = false;
	};

	control_canvas.onReleaseOutside = function () {
		is_seeking = false;
	};
};



/* Function: Time */

function fn_time() {
	time_slider._x = (duration_bar._width * (video_position / video_duration)) + 28;
};



/* Function: Progress */

function fn_progress() {
	progress_bar.lineTo(((duration_bar._width - 8) * (video_percent / 100)), 0);
};



/* Function: Fade In */

function fadeIn(mc, fadeRate, toAlpha) {
	toAlpha = toAlpha || 100;
	fadeRate = fadeRate || 20;

	mc.onEnterFrame = null;
	mc.onEnterFrame = function () {
		if (this._alpha >= toAlpha) {
			this._alpha = toAlpha;

			this.onEnterFrame = null;
		} else {
			this._alpha += fadeRate;
			this._alpha = Math.min(this._alpha, toAlpha);
		}
	};
};



/* Function: Fade Out */

function fadeOut(mc, fadeRate, toAlpha) {
	toAlpha = toAlpha || 0;
	fadeRate = fadeRate || 20;

	mc.onEnterFrame = null;
	mc.onEnterFrame = function () {
		if (this._alpha <= toAlpha) {
			this._alpha = toAlpha;

			this.onEnterFrame = null;
		} else {
			this._alpha -= Math.max(toAlpha - this._alpha - fadeRate, fadeRate, toAlpha);
		}
	};
};



/* Function: Controls Visible */

function fn_controls_visible(fadeRate) {
	if (!controls_override && controls_locked) {
		return;
	}

	controls_visible = true;
	fadeRate = fadeRate || 100;

	fadeIn(controls_bg, fadeRate, 70);
	if (is_playing) {
		fadeIn(pause_btn, fadeRate);
		play_btn._alpha = 0;
	}
	else {
		fadeIn(play_btn, fadeRate);
		pause_btn._alpha = 0;
	}
	fadeIn(duration_bar, fadeRate);
	fadeIn(progress_bar, fadeRate);
	fadeIn(time_slider, fadeRate);
	setTimeout(function () {
		duration_text_holder._visible = true;
	}, fadeRate);
	fadeIn(volume_btn, fadeRate);
	if (!is_muted) {
		fadeIn(volume_on_btn, fadeRate);
	}
	else {
		volume_on_btn._alpha = 0;
	}
};



/* Function: Controls Hidden */

function fn_controls_hidden(fadeRate) {
	controls_visible = false;

	fadeRate = fadeRate || 100;

	fadeOut(controls_bg, fadeRate);
	fadeOut(play_btn, fadeRate);
	fadeOut(pause_btn, fadeRate);
	fadeOut(duration_bar, fadeRate);
	fadeOut(progress_bar, fadeRate);
	fadeOut(time_slider, fadeRate);
	setTimeout(function () {
		duration_text_holder._visible = false;
	}, fadeRate);
	fadeOut(duration_text, fadeRate);
	fadeOut(volume_btn, fadeRate);
	fadeOut(volume_on_btn, fadeRate);
};



/* Function: Play */

function fn_play() {
	is_playing = true;

	if (stream.bytesLoaded && video_position != video_duration) {
		stream.pause();
	}
	else {
		stream.play(_root.src);
	}

	fn_controls_visible();

	rightClick.customItems.splice(0, 1, cmi_pause);
};


/* Function: Pause */

function fn_pause() {
	is_playing = false;

	stream.pause();

	video_position = stream.time;

	fn_controls_visible();

	rightClick.customItems.splice(0, 1, cmi_play);
};



/* Function: Mute & Unmute */

function fn_mute() {
	is_muted = true;

	audio.setVolume(0);

	fn_controls_visible();

	rightClick.customItems.splice(1, 1, cmi_unmute);
};

function fn_unmute() {
	is_muted = false;

	audio.setVolume(100);

	fn_controls_visible();

	rightClick.customItems.splice(1, 1, cmi_mute);
};



/* Function: Show Controls */

function fn_showcontrols() {
	rightClick.customItems.splice(2, 1, cmi_hidecontrols);

	controls_locked = false;

	fn_controls_visible();
};



/* Function: Hide Controls */

function fn_hidecontrols() {
	rightClick.customItems.splice(2, 1, cmi_showcontrols);

	fn_controls_hidden();

	controls_locked = true;
};



/* Function: Full Screen */

function fn_fullscreen() {
	Stage["displayState"] = "fullScreen";
};

Stage.addListener(fullscreen);
fullscreen.onFullScreen = function () {
	if (Stage["displayState"] == "normal") {
		controls_override = false;
		_root.menu = rightClick;
	}

	if (Stage["displayState"] == "fullScreen") {
		controls_override = true;
		_root.menu = rightClickBlank;
	}

	fn_controls_visible();
	display_init();

	controls_hover_timeout = 24 * 20;
};



/* Function: Keyboard Controls */


Key.addListener(keyboard);
keyboard.onKeyDown = function () {
	if (Key.isDown(Key.SPACE)) {
		if (!is_playing) {
			/* Play */
			fn_play();
		}
		else {
			/* Pause */
			fn_pause();
		}
	}
	if (Key.isDown(Key.CONTROL) && Key.isDown(Key.LEFT)) {
		stream.seek(Math.max(0, stream.time - (stream.duration / 10)));
		controls_hover_timeout = 24 * 12;
	}
	else if (Key.isDown(Key.CONTROL) && Key.isDown(Key.RIGHT)) {
		stream.seek(Math.min(video_duration, stream.time + (stream.duration / 10)));
		controls_hover_timeout = 24 * 12;
	}
	else if (Key.isDown(Key.CONTROL) && Key.isDown(Key.UP)) {
		if (is_muted) {
			fn_unmute();
		}
		controls_hover_timeout = 24 * 12;
	}
	else if (Key.isDown(Key.CONTROL) && Key.isDown(Key.DOWN)) {
		if (!is_muted) {
			/* Mute */
			fn_mute();
		}
		controls_hover_timeout = 24 * 12;
	}
	else if (Key.isDown(Key.LEFT)) {
		stream.seek(Math.max(0, stream.time - 15));
		controls_hover_timeout = 24 * 12;
	}
	else if (Key.isDown(Key.RIGHT)) {
		stream.seek(Math.min(video_duration, stream.time + 15));
		controls_hover_timeout = 24 * 12;
	}
};



/* Function: Display Init */

function display_init() {
	fn_draw_controls();
	fn_controls_visible();
	fn_resize_poster();
	fn_resize_video();
};


/* Right Click Menus */

var rightClick = new ContextMenu();
	rightClick.hideBuiltInItems();

var rightClickBlank = new ContextMenu();
	rightClickBlank.hideBuiltInItems();

var cmi_play = new ContextMenuItem("&Play ", fn_play);
var cmi_pause = new ContextMenuItem("&Pause ", fn_pause);
var cmi_mute = new ContextMenuItem("&Mute ", fn_mute);
var cmi_unmute = new ContextMenuItem("Un&mute ", fn_unmute);
var cmi_hidecontrols = new ContextMenuItem("Hide &Controls ", fn_hidecontrols);
var cmi_showcontrols = new ContextMenuItem("Show &Controls ", fn_showcontrols);
var cmi_fullscreen = new ContextMenuItem("&Full Screen ", fn_fullscreen);



/* Startup */

setInterval(
	function () {
		if (stream) {
			if (stream.bytesLoaded && stream.bytesTotal) {
				video_percent = (stream.bytesLoaded / stream.bytesTotal) * 100;
			}

			video_position = stream.time;
		}

		if (controls_visible && controls_hover_timeout <= 0 && first_hover) {
			/* Hide Controls */
			fn_controls_hidden(15);
		}
		else if (controls_visible) {
			controls_hover_timeout--;
		}

		fn_time();
		fn_progress();
	},
	9
);

display_init();

if (autoplay) {
	fn_play();
}

if (controls_locked) {
	rightClick.customItems.push(cmi_play, cmi_mute, cmi_showcontrols, cmi_fullscreen);
}
else {
	rightClick.customItems.push(cmi_play, cmi_mute, cmi_hidecontrols, cmi_fullscreen);
}

_root.menu = rightClick;


/* THIS STILL WONT WORK */

function jsInAs() {
	fn_play();
};

ExternalInterface.addCallback("jsToAs", this, jsInAs);

/* THIS STILL WONT WORK */