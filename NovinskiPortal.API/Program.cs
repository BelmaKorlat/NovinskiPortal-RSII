using Mapster;
using MapsterMapper;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using NovinskiPortal.Commom.PasswordService;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Database.Entities;
using NovinskiPortal.Services.Services.AdminService;
using NovinskiPortal.Services.Services.ArticleService;
using NovinskiPortal.Services.Services.AuthService;
using NovinskiPortal.Services.Services.CategoryService.CategoryService;
using NovinskiPortal.Services.Services.JwtService;
using NovinskiPortal.Services.Services.SubcategoryService.SubcategoryService;
using NovinskiPortal.Services.Services.UserService;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

var jwtSection = builder.Configuration.GetSection("Jwt");
var jwtKey = jwtSection["Key"];
var issuer = jwtSection["Issuer"];
var audience = jwtSection["Audience"];
var expiresInHours = int.Parse(jwtSection["ExpiresInHours"] ?? "2");

// Connection string iz appsettings.json
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<NovinskiPortalDbContext>(options => options.UseSqlServer(connectionString));

// Add services to the container.

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

    // Dodajemo security definiciju
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        In = ParameterLocation.Header,
        Description = "Unesite token tako da napišete 'Bearer <JWT>'",
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        BearerFormat = "JWT",
        Scheme = "Bearer"
    });

    // Dodajemo globalni security requirement - da se na sve endpointe koji traže auth automatski primjenjuje
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

builder.Services.AddSingleton(TypeAdapterConfig.GlobalSettings);
builder.Services.AddScoped<IMapper, ServiceMapper>();
// In your application startup (e.g., Program.cs or a dedicated config class):
TypeAdapterConfig<Subcategory, SubcategoryResponse>.NewConfig()
    .Map(dest => dest.CategoryName, src => src.Category.Name);

TypeAdapterConfig<User, UserAdminResponse>.NewConfig()
    .Map(dest => dest.RoleName, src => src.Role.Name)
    .Map(dest => dest.CreatedAt,
         src => DateTime.SpecifyKind(src.CreatedAt, DateTimeKind.Utc))
    .Map(dest => dest.LastLoginAt,
        src => src.LastLoginAt == null || src.LastLoginAt == default
        ? (DateTime?)null
        : DateTime.SpecifyKind(src.LastLoginAt.Value, DateTimeKind.Utc));

TypeAdapterConfig<User, UserResponse>.NewConfig()
    .Map(dest => dest.RoleName, src => src.Role.Name);

TypeAdapterConfig<Article, ArticleResponse>.NewConfig()
    .Map(d => d.CreatedAt,
         s => DateTime.SpecifyKind(s.CreatedAt, DateTimeKind.Utc))
    .Map(d => d.PublishedAt,
         s => DateTime.SpecifyKind(s.PublishedAt, DateTimeKind.Utc))
    .Map(d => d.Category, s => s.Category.Name)
    .Map(d => d.Subcategory, s => s.Subcategory.Name)
    .Map(d => d.User, s => s.HideFullName ? s.User.Nick : s.User.FirstName + " " + s.User.LastName)
    .Map(d => d.Color, s => s.Category.Color);

TypeAdapterConfig<Article, ArticleDetailResponse>.NewConfig()
     .Map(d => d.CreatedAt,
         s => DateTime.SpecifyKind(s.CreatedAt, DateTimeKind.Utc))
    .Map(d => d.PublishedAt,
         s => DateTime.SpecifyKind(s.PublishedAt, DateTimeKind.Utc))
    .Map(d => d.Category, s => s.Category.Name)
    .Map(d => d.Subcategory, s => s.Subcategory.Name)
    .Map(d => d.User, s => s.HideFullName ? s.User.Nick : s.User.FirstName + " " + s.User.LastName)
    .Map(d => d.Color, s => s.Category.Color)
    .Map(d => d.AdditionalPhotos, s => s.ArticlePhotos.Select(p => p.PhotoPath).ToList());



builder.Services.AddScoped<ICategoryService, CategoryService>();
builder.Services.AddScoped<ISubcategoryService, SubcategoryService>();
builder.Services.AddScoped<IPasswordService, PasswordService>();
builder.Services.AddScoped<IJwtService, JwtService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IAdminUserService, AdminUserService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IArticleService, ArticleService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI();
}

// app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
