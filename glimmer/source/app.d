import std;
import glim;

void raytracerTest()
{
	// Create a new world
	const world = cast(Renderable[])[
		Renderable(new Sphere(Vec3(-1, 0, -4), 0.5), new Glass(RGBA.white, 1.54)),
		Renderable(new Sphere(Vec3(-1, 0, -4), 0.45), new Glass(RGBA.white,
				Glass.AIR_REFRACTIVE_INDEX, 1.54, false)),
		Renderable(new Sphere(Vec3(0, 0, -4), 0.5), new Lambertian(RGBA.opaque(0.6, 0.1, 0.4)),),
		Renderable(new Sphere(Vec3(1, 0, -4), 0.5), new Metallic(RGBA.opaque(1.0, 0.8, 0), 1.0)),
		// Renderable(new Sphere(Vec3(0, -100.5, -5), 100), new Lambertian(RGBA.opaque(0.2, 0.7, 0.3))),
	];

	auto skybox = new GradientSkybox(RGBA.white, RGBA.opaque(0.1, 0.3, 0.9),
			RGBA.black.lerp(RGBA.white, 0.1));

	// Create a new camera at origin
	const camera = Camera.builder() //
	.position(Vec3.zero) //
	.target(Vec3(0, 0, -3.5)) //
	.extent(1200, 800) //
	.verticalFov(30) //
	.skybox(skybox).build();

	immutable Raytracer.Params rtParams = {
		samplesPerPx: 100, //
		maxBounces: 10, //
		numThreads: 20,
	};

	// Create the ray tracer
	auto tracer = new Raytracer(camera, world, rtParams);

	// Perform a render of the world
	tracer.renderSingleThreaded();

	// Encode the camera buffer to a file
	tracer.encodeToFile(new PNGEncoder, "render.png");
}

void rasterizerTest()
{
	// Create a new camera
	const camera = Camera.builder().extent(300, 220).position(Vec3.zero)
		.target(Vec3(0, 0, -3.5)).verticalFov(60).build();

	immutable Rasterizer.Params rastParams = {};

	// Create the rasterizer
	auto rasterizer = new Rasterizer(camera, rastParams);

	rasterizer.render();
	rasterizer.encodeToFile(new PNGEncoder, "render.png");
}

void main()
{
	rasterizerTest();
}
