import std.stdio;
import std.algorithm.comparison;

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
	env["left"] = new Sphere(Vec3(-1, 0, -4), 0.5);
	env["sphere"] = new Sphere(Vec3(0, 0, -4), 0.5);
	env["right"] = new Sphere(Vec3(1, 0, -4), 0.5);
	env["ground"] = new Sphere(Vec3(0, -100.5, -5), 100);

	// Set materials
	env["left"] = new Metallic(RGBA.same(0.8), 0.0);
	env["sphere"] = new Lambertian(RGBA.opaque(0.6, 0.1, 0.4));
	env["right"] = new Metallic(RGBA.opaque(1.0, 0.8, 0), 1.0);
	env["ground"] = new Lambertian(RGBA.opaque(0.2, 0.7, 0.3));

	// Create a new camera at origin
	auto cam = new CameraBuilder().width(1280).height(720).fov(10)
		.samplesPerPx(100).maxBounces(50).build;

	// Perform a render of the world
	cam.render(env);

	// Encode the camera buffer to a file
	auto enc = new PPMEncoder();
	cam.encodeToFile(enc, "image.ppm");
}
