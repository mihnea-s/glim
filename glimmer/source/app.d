import std.stdio;
import std.format;
import std.algorithm.comparison;
import std.math;

import glim.image;
import glim.math;
import glim.camera;
import glim.materials;
import glim.shapes;
import glim.world;

void main()
{
	// Create a new world
	auto env = new World;

	// Set shapes
	env["0"] = new Sphere(Vec3(-1.125, 0, -5), 0.5);
	env["1"] = new Sphere(Vec3(-0.375, 0, -4), 0.5);
	env["2"] = new Sphere(Vec3(+0.375, 0, -3), 0.5);
	env["3"] = new Sphere(Vec3(+1.125, 0, -2), 0.5);
	env["ground"] = new Sphere(Vec3(0, -100.5, -5), 100);

	// Set materials
	env["0"] = new Metallic(RGBA.opaque(0.4, 0.2, 0.8), 0.0);
	env["1"] = new Lambertian(RGBA.opaque(0.7, 0.1, 0.1));
	env["2"] = new Glass(RGBA.white, 1.5);
	env["3"] = new Metallic(RGBA.opaque(1.0, 1.0, 0.0), 1.0);
	env["ground"] = new Lambertian(RGBA.opaque(0.2, 0.7, 0.3));

	// Create a new camera at origin
	auto cam = new CameraBuilder().position(Vec3(10, 10, 0)).width(600)
		.height(300).lookAt(Vec3(0, 0, -3.5)).vfov(30).samplesPerPx(100)
		.maxBounces(50).numThreads(10).aperture(0).focusDistance(0.1).build;

	foreach (_; 0 .. 10)
	{
		// Perform a render of the world
		cam.renderMultiThreaded(env);
	}
}
