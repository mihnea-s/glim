module example.app;

import std.stdio;
import std.algorithm.comparison;

import glimmer.image;
import glimmer.math;
import glimmer.camera;
import glimmer.shapes;

void main()
{
	auto img = RGBABuffer.fromWH(200 * 10, 100 * 10);
	auto cam = new Camera();

	auto topRight = Vec3(-2, 1, -1);
	auto horizontal = Vec3(4, 0, 0);
	auto vertical = Vec3(0, 2, 0);

	foreach (ulong i; 0 .. img.height)
	{
		foreach (ulong j; 0 .. img.width)
		{
			auto u = cast(double)(i) / img.height;
			auto v = cast(double)(j) / img.width;

			auto ray = Ray.originTo(topRight + horizontal * v - vertical * u);
			img[i, j] = cam.colorOf(ray);
		}
	}

	auto enc = new PPMEncoder();
	enc.encodeToFile(img, "test.ppm");
}
