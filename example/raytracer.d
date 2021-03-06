/+ dub.sdl:
	name "glim-example"
	description "Glim example"

	targetType "executable"
	targetPath "../../build"

	dependency "glim" version="*" path="../.."
+/

import std;
import glim;

void main()
{
	// Create a new world
	const world = [
		Renderable(new Sphere(Vec3(-1, 0, -4), 0.5), new Glass(RGBA.white, 1.54)),
		Renderable(new Sphere(Vec3(0, 0, -4), 0.5), new Lambertian(RGBA.opaque(0.6, 0.1, 0.4)),),
		Renderable(new Sphere(Vec3(1, 0, -4), 0.5), new Metallic(RGBA.opaque(1.0, 0.8, 0), 1.0)),
		Renderable(new Sphere(Vec3(0, -100.5, -5), 100), new Lambertian(RGBA.opaque(0.2, 0.7, 0.3))),
	];

	// Create a new camera at origin
	const camera = Camera.builder() //
	.position(Vec3.zero) //
	.target(Vec3(0, 0, -3.5)) //
	.extent(1280, 720) //
	.verticalFov(30) //
	.build();

	immutable Raytracer.Params rtParams = {
		samplesPerPx: 100, //
		maxBounces: 50, //
		numThreads: 20,
	};

	// Create the ray tracer
	auto tracer = new Raytracer(camera, world, rtParams);

	// Perform a render of the world
	tracer.renderMultiThreaded();

	// Encode the camera buffer to a file
	tracer.encodeToFile(new PNGEncoder, "eg_materials.png");
}
