using Mapster;
using MapsterMapper;
using NovinskiPortal.API.Mapping;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using NovinskiPortal.Commom.PasswordService;
using NovinskiPortal.Common.Messaging;
using NovinskiPortal.Common.Settings;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Implementations;
using NovinskiPortal.Services.Messaging;
using NovinskiPortal.Services.Seeding;
using NovinskiPortal.Services.Services.AdminCommentService;
using NovinskiPortal.Services.Services.AdminDashboardService;
using NovinskiPortal.Services.Services.AdminService;
using NovinskiPortal.Services.Services.ArticleCommentReportService;
using NovinskiPortal.Services.Services.ArticleCommentService;
using NovinskiPortal.Services.Services.ArticleCommentVoteService;
using NovinskiPortal.Services.Services.ArticleReadService;
using NovinskiPortal.Services.Services.ArticleService;
using NovinskiPortal.Services.Services.AuthService;
using NovinskiPortal.Services.Services.CategoryService.CategoryService;
using NovinskiPortal.Services.Services.EmailService;
using NovinskiPortal.Services.Services.FavoriteService;
using NovinskiPortal.Services.Services.JwtService;
using NovinskiPortal.Services.Services.NewsReportService;
using NovinskiPortal.Services.Services.RecommendationService;
using NovinskiPortal.Services.Services.SubcategoryService.SubcategoryService;
using NovinskiPortal.Services.Services.UserService;
using QuestPDF.Infrastructure;
using System.Text.Json.Serialization;
using Microsoft.Data.SqlClient;

var builder = WebApplication.CreateBuilder(args);

var jwtSection = builder.Configuration.GetSection("Jwt");
var jwtKey = jwtSection["Key"];
var issuer = jwtSection["Issuer"];
var audience = jwtSection["Audience"];
var expiresInHours = int.Parse(jwtSection["ExpiresInHours"] ?? "2");

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<NovinskiPortalDbContext>(options => options.UseSqlServer(connectionString));

builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
});

builder.Services
    .AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    })
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;

    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = issuer,
        ValidAudience = audience,
        IssuerSigningKey = new SymmetricSecurityKey(System.Text.Encoding.UTF8.GetBytes(jwtKey!))
    };
});

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "My API", Version = "v1" });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        In = ParameterLocation.Header,
        Description = "Unesite token tako da napišete 'Bearer <JWT>'",
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        BearerFormat = "JWT",
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement {
    {
       new OpenApiSecurityScheme {
         Reference = new OpenApiReference {
           Type = ReferenceType.SecurityScheme,
           Id = "Bearer"
         }
       },
       new string[] {}
    }});
});

builder.Services.AddRazorPages();

builder.Services.Configure<SmtpSettings>(builder.Configuration.GetSection("Smtp"));

builder.Services.Configure<RabbitMqSettings>(builder.Configuration.GetSection("RabbitMq"));
QuestPDF.Settings.License = LicenseType.Community;

var mapsterConfig = TypeAdapterConfig.GlobalSettings;
MapsterConfig.RegisterMappings(mapsterConfig);

builder.Services.AddSingleton(mapsterConfig);

builder.Services.AddSingleton<IEventPublisher, RabbitMqEventPublisher>();
builder.Services.AddScoped<IMapper, ServiceMapper>();

builder.Services.AddScoped<ICategoryService, CategoryService>();
builder.Services.AddScoped<ISubcategoryService, SubcategoryService>();
builder.Services.AddScoped<IPasswordService, PasswordService>();
builder.Services.AddScoped<IJwtService, JwtService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IAdminUserService, AdminUserService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IArticleService, ArticleService>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<IFavoriteService, FavoriteService>();
builder.Services.AddScoped<INewsReportService, NewsReportService>();
builder.Services.AddScoped<IArticleCommentService, ArticleCommentService>();
builder.Services.AddScoped<IArticleCommentVoteService, ArticleCommentVoteService>();
builder.Services.AddScoped<IArticleCommentReportService, ArticleCommentReportService>();
builder.Services.AddScoped<IAdminCommentService, AdminCommentService>();
builder.Services.AddScoped<IArticleReadService, ArticleReadService>();
builder.Services.AddScoped<IRecommendationService, RecommendationService>();
builder.Services.AddScoped<IAdminDashboardService, AdminDashboardService>();

var app = builder.Build();

await EnsureDatabaseReadyAsync(app);


app.UseDeveloperExceptionPage();
app.UseSwagger();
app.UseSwaggerUI();


// app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapRazorPages();

static async Task EnsureDatabaseReadyAsync(WebApplication app)
{
    var retries = 0;
    const int maxRetries = 10;

    while (true)
    {
        try
        {
            await DbSeeder.SeedAsync(app.Services);
            break;
        }
        catch (SqlException ex)
        {
            retries++;

            if (retries >= maxRetries)
            {
                throw;
            }

            await Task.Delay(TimeSpan.FromSeconds(5));
        }
    }
}

app.Run();
