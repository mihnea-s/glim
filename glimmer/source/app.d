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
	env["0"] = new Sphere(Vec3(-1.5, 0, -4), 0.5);
	env["1"] = new Sphere(Vec3(-.5, 0, -4), 0.5);
	env["2"] = new Sphere(Vec3(+.5, 0, -4), 0.5);
	env["3"] = new Sphere(Vec3(+1.5, 0, -4), 0.5);
	env["ground"] = new Sphere(Vec3(0, -100.5, -5), 100);

	// Set materials
	env["0"] = new Metallic(RGBA.same(0.8), 0.0);
	env["1"] = new Lambertian(RGBA.opaque(0.6, 0.1, 0.4));
	env["2"] = new Glass(RGBA.opaque(0.2, 0.5, 0.8), 1.5);
	env["3"] = new Metallic(RGBA.opaque(1.0, 0.8, 0), 1.0);
	env["ground"] = new Lambertian(RGBA.opaque(0.2, 0.7, 0.3));

	// Create a new camera at origin
	auto cam = new CameraBuilder().width(1280).height(720).fov(10)
		.samplesPerPx(500).maxBounces(75).build;

	// Perform a render of the world
	cam.render(env);

	// Encode the camera buffer to a file
	auto enc = new PPMEncoder();
	cam.encodeToFile(enc, "image.ppm");
}
