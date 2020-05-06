module example.app;

import std.stdio;
import std.algorithm.comparison;

import glim.image;
import glim.math;
import glim.camera;
import glim.shapes;
import glim.world;

void main()
{
	auto env = new World;
	env["shape1"] = new Sphere(Vec3(0, 0, -5), 0.5);
	env["shape2"] = new Sphere(Vec3(0, -100.4, -5), 100);

	auto cam = new CameraBuilder() //
	.fov(9) //
	.samplesPerPx(100) //
	.build;

	cam.render(env);

	auto enc = new PPMEncoder();
	cam.encodeToFile(enc, "image.ppm");
}
