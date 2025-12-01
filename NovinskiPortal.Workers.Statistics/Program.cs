using Mapster;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Common.Settings;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Services.ArticleService;
using NovinskiPortal.Services.Services.BaseService;
using NovinskiPortal.Workers.Statistics;

var builder = Host.CreateApplicationBuilder(args);
builder.Services.Configure<RabbitMqSettings>(builder.Configuration.GetSection("RabbitMq"));

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<NovinskiPortalDbContext>(options =>
{
    options.UseSqlServer(connectionString);
});

builder.Services.AddSingleton(TypeAdapterConfig.GlobalSettings);
builder.Services.AddScoped<IMapper, ServiceMapper>();

builder.Services.AddScoped<IArticleService, ArticleService>();
builder.Services.AddHostedService<ArticleViewedWorker>();

var host = builder.Build();
host.Run();
