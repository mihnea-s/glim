module example.app;

import std.stdio;
import std.algorithm.comparison;

import glimmer.image;
import glimmer.math;
import glimmer.camera;
import glimmer.shapes;
import glimmer.world;

void main()
{
	auto env = new World;
	env["shape1"] = new Sphere(Vec3(0, 0, -5), 0.5);
	env["shape2"] = new Sphere(Vec3(-2, 1, -3), 1.5);

	auto cam = new Camera(Vec3.zero, 1920, 1080);
	cam.render(env);

	auto enc = new PPMEncoder();
	cam.encodeToFile(enc, "image.ppm");
}
