import std.stdio;
import std.format;
import std.algorithm.comparison;
import std.math;

import glim.image;
import glim.math;
import glim.rendering;
import glim.materials;
import glim.shapes;

void main()
{
	// Create a new world
	auto env = new World;

	// Set shapes
	env["out"] = new Sphere(Vec3(0, 0, -5), 1.0);
	env["in"] = new Sphere(Vec3(0, 0, -5), 0.9);
	env["0"] = new Sphere(Vec3(2.25, 0, -5), 1.0);
	env["1"] = new Sphere(Vec3(-2.25, 0, -5), 1.0);
	env["ground"] = new Sphere(Vec3(0, -101, -5), 100);

	// Set materials
	env["out"] = new Glass(RGBA.white, 1.5);
	env["in"] = new Glass(RGBA.white, 1.0, 1.5, false);
	env["0"] = new Lambertian(RGBA.opaque(0.9, 0.5, 0.3));
	env["1"] = new Lambertian(RGBA.opaque(0.2, 0.3, 0.9));
	env["ground"] = new Lambertian(RGBA.opaque(0.2, 0.7, 0.3));

	immutable Camera.Params camParams = {
		position: Vec3.zero, //
		target: Vec3(0, 0, -3.5), //

		width: 600, //
		height: 300, //

		verticalFov: 60, //
		samplesPerPx: 100, //
		maxBounces: 50, //
		numThreads: 10,
	};

	// Create a new camera
	auto cam = new Camera(camParams);

	cam.renderMultiThreaded(env);
	cam.encodeToFile(new PNGEncoder, "render.png");
}
