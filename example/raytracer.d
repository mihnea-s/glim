#!/usr/bin/env dub

/+ dub.sdl:
	name "glim-example-raytracer"
	description "Glim example using the Raytracer"

	targetType "executable"
	targetPath "../build"

	dependency "glim" version="*" path=".."
+/

import std;
import glim;

void main()
{
	// Create a new world
	const world = [
		Raytraced(
			new Sphere(Vec3(-0.55, -0.5, -4), 0.5), 
			new Glass(RGBA.white, Glass.AIR_REFRACTIVE_INDEX)
		),
		
		Raytraced(
			new Sphere(Vec3(0, 0.5, -4), 0.5),
			new Lambertian(RGBA.opaque(0.6, 0.1, 0.4)),
		),

		Raytraced(
			new Sphere(Vec3(0.55, -0.5, -4), 0.5),
			new Metallic(RGBA.opaque(1.0, 0.8, 0), 0.35)
		),

		Raytraced(
			new Sphere(Vec3(0, 0, -7), 1),
			new Lambertian(RGBA.opaque(0.2, 0.7, 0.3))
		),
	];

	// Unity skybox
	auto skybox = new GradientSkybox(
		RGBA.white,
		RGBA.opaque(0.1, 0.3, 0.9),
		RGBA.black.lerp(RGBA.white, 0.1),
	);

	// Create a new camera at origin
	const camera = Camera.builder()
		.position(Vec3.zero)
		.target(Vec3(0, 0, -4))
		.extent(1280, 720)
		.verticalFov(30)
		.skybox(skybox)
		.build();

	immutable Raytracer.Params rtParams = {
		samplesPerPx: 100, //
		maxBounces: 50, //
		numThreads: 20,
	};

	// Create the ray tracer
	auto renderer = new Raytracer(camera, world, rtParams);

	// Perform a render of the world
	renderer.renderMultiThreaded();

	// Encode the camera buffer to a file
	(new PNGEncoder).encodeToFile(renderer.buffer, "renders/ex_raytracer.png");
}
