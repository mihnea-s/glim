#!/usr/bin/env dub

/+ dub.sdl:
	name "glim-example-rasterizer"
	description "Glim example using the Rasterizer"

	targetType "executable"
	targetPath "../build"

	dependency "glim" version="*" path=".."
+/

import std;
import glim;

void main()
{
	// Create a new world
	const world = [];

	// Create a new camera at origin
	const camera = Camera.builder()
		.position(-3 * Vec3.forward)
		.target(Vec3.zero)
		.extent(720, 720)
		.verticalFov(60)
		.build();

	immutable Rasterizer.Params raParams = {
		mode: RasterMode.Triangles,
	};

	// Create the ray tracer
	auto renderer = new Rasterizer(camera, world, raParams);

	// Perform a render of the world
	renderer.render();

	// Encode the camera buffer to a file
	(new PNGEncoder).encodeToFile(tracer.buffer, "eg_rasterize.png");
}
