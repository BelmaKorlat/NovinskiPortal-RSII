using Mapster;
using MapsterMapper;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using NovinskiPortal.Commom.PasswordService;
using NovinskiPortal.Common.Enumerations;
using NovinskiPortal.Common.Messaging;
using NovinskiPortal.Common.Settings;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Database.Entities;
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
using NovinskiPortal.Services.Services.BaseService;
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

builder.Services.AddSingleton(TypeAdapterConfig.GlobalSettings);
builder.Services.AddSingleton<IEventPublisher, RabbitMqEventPublisher>();
builder.Services.AddScoped<IMapper, ServiceMapper>();

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
    .Map(d => d.Color, s => s.Category.Color)
    .Map(d => d.CommentsCount, s => s.ArticleComments.Count(c => !c.IsDeleted && !c.IsHidden));

TypeAdapterConfig<Article, ArticleDetailResponse>.NewConfig()
     .Map(d => d.CreatedAt,
         s => DateTime.SpecifyKind(s.CreatedAt, DateTimeKind.Utc))
    .Map(d => d.PublishedAt,
         s => DateTime.SpecifyKind(s.PublishedAt, DateTimeKind.Utc))
    .Map(d => d.Category, s => s.Category.Name)
    .Map(d => d.Subcategory, s => s.Subcategory.Name)
    .Map(d => d.User, s => s.HideFullName ? s.User.Nick : s.User.FirstName + " " + s.User.LastName)
    .Map(d => d.Color, s => s.Category.Color)
    .Map(d => d.AdditionalPhotos, s => s.ArticlePhotos.Select(p => p.PhotoPath).ToList())
    .Map(d => d.CommentsCount, s => s.ArticleComments.Count(c => !c.IsDeleted && !c.IsHidden));

TypeAdapterConfig<Favorite, FavoriteResponse>.NewConfig()
    .Map(d => d.Id, s => s.Id)
    .Map(d => d.CreatedAt,
         s => DateTime.SpecifyKind(s.CreatedAt, DateTimeKind.Utc))
    .Map(d => d.Article, s => s.Article);

TypeAdapterConfig<NewsReport, NewsReportResponse>.NewConfig()
    .Map(d => d.UserFullName, s => s.User != null ? s.User.FirstName + " " + s.User.LastName: null)
    .Map(d => d.CreatedAt,
         s => DateTime.SpecifyKind(s.CreatedAt, DateTimeKind.Utc))
    .Map(d => d.ProcessedAt,
         s => s.ProcessedAt.HasValue
             ? DateTime.SpecifyKind(s.ProcessedAt.Value, DateTimeKind.Utc)
             : (DateTime?)null);

TypeAdapterConfig<ArticleComment, ArticleCommentResponse>.NewConfig()
    .Map(d => d.Username, s => s.User != null
              ? s.User.Username            
              : null)
    .Map(d => d.CreatedAt,
         s => DateTime.SpecifyKind(s.CreatedAt, DateTimeKind.Utc));

TypeAdapterConfig<ArticleComment, AdminCommentReportResponse>.NewConfig()
    .Map(d => d.ArticleHeadline, s => s.Article.Headline)
    .Map(d => d.CommentAuthorId, s => s.UserId)
    .Map(d => d.CommentAuthorUsername, s => s.User.Username)
    .Map(d => d.ReportsCount, s => s.ReportsCount)
    .Map(d => d.PendingReportsCount,
         s => s.Reports == null
              ? 0
              : s.Reports.Count(r => r.Status == ArticleCommentReportStatus.Pending))
    .Map(d => d.FirstReportedAt,
         s => s.Reports == null || !s.Reports.Any()
              ? (DateTime?)null
              : DateTime.SpecifyKind(
                    s.Reports.Min(r => r.CreatedAt),
                    DateTimeKind.Utc))
    .Map(d => d.LastReportedAt,
         s => s.Reports == null || !s.Reports.Any()
              ? (DateTime?)null
              : DateTime.SpecifyKind(
                    s.Reports.Max(r => r.CreatedAt),
                    DateTimeKind.Utc))
    .Map(d => d.HasPendingReports,
         s => s.Reports != null &&
              s.Reports.Any(r => r.Status == ArticleCommentReportStatus.Pending));


TypeAdapterConfig<ArticleComment, AdminCommentDetailReportResponse>.NewConfig()
    .Map(d => d.ArticleHeadline, s => s.Article.Headline)
    .Map(d => d.CommentAuthorId, s => s.UserId)
    .Map(d => d.CommentAuthorUsername, s => s.User.Username)
    .Map(d => d.CommentCreatedAt,
         s => DateTime.SpecifyKind(s.CreatedAt, DateTimeKind.Utc))
    .Map(d => d.ReportsCount, s => s.ReportsCount)
    .Map(d => d.PendingReportsCount,
         s => s.Reports != null
              ? s.Reports.Count(r => r.Status == ArticleCommentReportStatus.Pending)
              : 0)
    .Map(d => d.FirstReportedAt,
         s => s.Reports != null && s.Reports.Count > 0
              ? DateTime.SpecifyKind(
                    s.Reports.Min(r => r.CreatedAt),
                    DateTimeKind.Utc)
              : (DateTime?)null)
    .Map(d => d.LastReportedAt,
         s => s.Reports != null && s.Reports.Count > 0
              ? DateTime.SpecifyKind(
                    s.Reports.Max(r => r.CreatedAt),
                    DateTimeKind.Utc)
              : (DateTime?)null)
    .Map(d => d.AuthorCommentBanUntil,
         s => s.User.CommentBanUntil == null
              ? (DateTime?)null
              : DateTime.SpecifyKind(
                    s.User.CommentBanUntil.Value,
                    DateTimeKind.Utc))
    .Map(d => d.AuthorCommentBanReason, s => s.User.CommentBanReason)
    .Map(d => d.Reports,
         s => (s.Reports ?? new List<ArticleCommentReport>())
                .OrderByDescending(r => r.CreatedAt)
                .Adapt<List<AdminCommentItemReportResponse>>());

     
TypeAdapterConfig<ArticleCommentReport, AdminCommentItemReportResponse>
    .NewConfig()
    .Map(d => d.ReporterUsername, s => s.ReporterUser.Username)
    .Map(d => d.CreatedAt,
         s => DateTime.SpecifyKind(s.CreatedAt, DateTimeKind.Utc))
    .Map(d => d.ProcessedAt,
         s => s.ProcessedAt.HasValue
              ? DateTime.SpecifyKind(s.ProcessedAt.Value, DateTimeKind.Utc)
              : (DateTime?)null)
    .Map(d => d.ProcessedByAdminUsername,
         s => s.ProcessedByAdmin != null ? s.ProcessedByAdmin.Username : null);


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
