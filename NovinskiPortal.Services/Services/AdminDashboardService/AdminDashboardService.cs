using NovinskiPortal.Model.Responses;
using NovinskiPortal.Services.Database;
using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;


namespace NovinskiPortal.Services.Services.AdminDashboardService
{
    public class AdminDashboardService : IAdminDashboardService
    {

        private readonly NovinskiPortalDbContext _context;

        public AdminDashboardService(NovinskiPortalDbContext context)
        {
            _context = context;
        }
        public async Task<AdminDashboardSummaryResponse> GetSummaryAsync()
        {
            var now = DateTime.UtcNow;
            var sevenDaysAgo = now.AddDays(-7);
            var thirtyDaysAgo = now.AddDays(-30);

            var totalArticles = await _context.Articles.CountAsync();

            var totalUsers = await _context.Users.CountAsync();

            var viewsLast7Days = await _context.UserArticleViews
                .Where(x => x.ViewedAt >= sevenDaysAgo)
                .CountAsync();

            var newArticlesLast7Days = await _context.Articles
                .Where(a => a.PublishedAt >= sevenDaysAgo)
                .CountAsync();

            var topArticles = await GetTopArticlesAsync(
                categoryId: null,
                from: null,
                to: null,
                take: 15);

            var dailyArticlesRaw = await _context.Articles
                .Where(a => a.PublishedAt >= thirtyDaysAgo)
                .GroupBy(a => a.PublishedAt.Date)
                .Select(g => new
                {
                    Date = g.Key,
                    Count = g.Count()
                })
                .ToListAsync();

            var dailyArticles = new List<DailyArticlesDashboardResponse>();
            for (var date = thirtyDaysAgo.Date; date <= now.Date; date = date.AddDays(1))
            {
                var match = dailyArticlesRaw.FirstOrDefault(x => x.Date == date);
                dailyArticles.Add(new DailyArticlesDashboardResponse
                {
                    Date = date,
                    TotalArticles = match?.Count ?? 0
                });
            }

            var categoryViewsRaw = await _context.UserArticleViews
                .Include(v => v.Article)
                .ThenInclude(a => a.Category)
                .Where(v => v.ViewedAt >= thirtyDaysAgo)
                .GroupBy(v => new
                {
                    v.Article.CategoryId,
                    v.Article.Category.Name
                })
                .Select(g => new
                {
                    CategoryId = g.Key.CategoryId,
                    CategoryName = g.Key.Name,
                    TotalViews = g.Count()
                })
                .OrderByDescending(x => x.TotalViews)
                .ToListAsync();

            var categoryViews = categoryViewsRaw
                .Select(x => new CategoryViewsDashboardResponse
                {
                    CategoryId = x.CategoryId,
                    CategoryName = x.CategoryName,
                    TotalViews = x.TotalViews
                })
                .ToList();

            var result = new AdminDashboardSummaryResponse
            {
                TotalArticles = totalArticles,
                TotalUsers = totalUsers,
                ViewsLast7Days = viewsLast7Days,
                NewArticlesLast7Days = newArticlesLast7Days,
                TopArticles = topArticles,
                DailyArticlesLast30Days = dailyArticles,
                CategoryViewsLast30Days = categoryViews
            };

            return result;
        }

        public async Task<List<TopArticleDashboardResponse>> GetTopArticlesAsync(int? categoryId, DateTime? from, DateTime? to, int take = 15)
        {
            var hasDateFilter = from.HasValue || to.HasValue;

            if (!hasDateFilter)
            {
                var query = _context.ArticleStatistics
                    .Include(s => s.Article)
                        .ThenInclude(a => a.Category)
                    .AsQueryable();

                if (categoryId.HasValue)
                {
                    query = query.Where(s => s.Article.CategoryId == categoryId.Value);
                }

                return await query
                    .OrderByDescending(s => s.TotalViews)
                    .Take(take)
                    .Select(s => new TopArticleDashboardResponse
                    {
                        ArticleId = s.ArticleId,
                        Title = s.Article.Headline,
                        CategoryId = s.Article.CategoryId,
                        CategoryName = s.Article.Category.Name,
                        TotalViews = s.TotalViews
                    })
                    .ToListAsync();
            }

            var viewsQuery = _context.UserArticleViews
                .Include(v => v.Article)
                    .ThenInclude(a => a.Category)
                .AsQueryable();

            if (from.HasValue)
            {
                var fromDate = from.Value.Date;
                viewsQuery = viewsQuery.Where(v => v.ViewedAt >= fromDate);
            }

            if (to.HasValue)
            {
                var toExclusive = to.Value.Date.AddDays(1);
                viewsQuery = viewsQuery.Where(v => v.ViewedAt < toExclusive);
            }

            if (categoryId.HasValue)
            {
                viewsQuery = viewsQuery.Where(v => v.Article.CategoryId == categoryId.Value);
            }

            var list = await viewsQuery
                .GroupBy(v => new
                {
                    v.ArticleId,
                    v.Article.Headline,
                    v.Article.CategoryId,
                    CategoryName = v.Article.Category.Name
                })
                .Select(g => new TopArticleDashboardResponse
                {
                    ArticleId = g.Key.ArticleId,
                    Title = g.Key.Headline,
                    CategoryId = g.Key.CategoryId,
                    CategoryName = g.Key.CategoryName,
                    TotalViews = g.Count()
                })
                .OrderByDescending(x => x.TotalViews)
                .Take(take)
                .ToListAsync();

            return list;
        }


        public async Task<byte[]> GenerateTopArticlesPdfAsync(
           int? categoryId,
           DateTime? from,
           DateTime? to,
           int take = 15)
        {
            var items = await GetTopArticlesAsync(categoryId, from, to, take);

            var totalViews = items.Sum(x => x.TotalViews);
            var totalArticles = items.Count;
            var avgViews = totalArticles > 0
                ? (double)totalViews / totalArticles
                : 0;

            var bestArticle = items
                .OrderByDescending(x => x.TotalViews)
                .FirstOrDefault();

            var categoryAggregates = items
                .GroupBy(a => a.CategoryName ?? "Bez kategorije")
                .Select(g => new
                {
                    CategoryName = g.Key,
                    Articles = g.Count(),
                    Views = g.Sum(x => x.TotalViews)
                })
                .OrderByDescending(x => x.Views)
                .ToList();

            string periodText;
            if (from.HasValue && to.HasValue)
                periodText = $"{from:dd.MM.yyyy} - {to:dd.MM.yyyy}";
            else if (from.HasValue)
                periodText = $"Od {from:dd.MM.yyyy}";
            else if (to.HasValue)
                periodText = $"Do {to:dd.MM.yyyy}";
            else
                periodText = "Svi datumi";

            string categoryText;
            if (categoryId.HasValue)
            {
                categoryText = await _context.Categories
                    .Where(c => c.Id == categoryId.Value)
                    .Select(c => c.Name)
                    .FirstOrDefaultAsync() ?? "Nepoznata kategorija";
            }
            else
            {
                categoryText = "Sve kategorije";
            }

            var generatedAt = DateTime.Now;

            var brandBlue = Color.FromHex("#1976D2");      
            var brandGrayBackground = Colors.Grey.Lighten4;

            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(40);
                    page.PageColor(brandGrayBackground);

                    page.Content().Column(col =>
                    {
                        col.Spacing(20); 

                        col.Item().Container().Background(brandBlue).Padding(16).Row(row =>
                        {
                            row.RelativeItem().Column(headerCol =>
                            {
                                headerCol.Spacing(4);

                                headerCol.Item().Text("NovinskiPortal")
                                    .FontSize(18)
                                    .Bold()
                                    .FontColor(Colors.White);

                                headerCol.Item().Text("Izvještaj čitanosti - najčitaniji članci")
                                    .FontSize(12)
                                    .FontColor(Colors.White);
                            });

                     
                        });

                        col.Item().Container().Background(Colors.White).Padding(16).Column(infoCol =>
                        {
                            infoCol.Spacing(6);

                            infoCol.Item().Text("Detalji izvještaja")
                                .FontSize(14)
                                .Bold();

                            infoCol.Item().Text($"Period: {periodText}")
                                .FontSize(11);

                            infoCol.Item().Text($"Kategorija: {categoryText}")
                                .FontSize(11);

                            infoCol.Item().Text($"Generisano: {generatedAt:dd.MM.yyyy HH:mm}")
                                .FontSize(9)
                                .FontColor(Colors.Grey.Darken2);
                        });

                        col.Item().Container().Background(Colors.White).Padding(16).Row(row =>
                        {
                            void StatCard(string title, string value, string hint)
                            {
                                row.RelativeItem().PaddingRight(8).Column(card =>
                                {
                                    card.Spacing(4);

                                    card.Item().Text(title)
                                        .FontSize(10)
                                        .FontColor(Colors.Grey.Darken2);

                                    card.Item().Text(value)
                                        .FontSize(14)
                                        .SemiBold();

                                    card.Item().Text(hint)
                                        .FontSize(9)
                                        .FontColor(Colors.Grey.Darken1);
                                });
                            }

                            StatCard(
                                "Broj članaka u izvještaju",
                                totalArticles.ToString(),
                                "Ukupan broj redova u tabeli");

                            StatCard(
                                "Ukupan broj pregleda",
                                totalViews.ToString(),
                                "Zbir pregleda svih članaka");

                            StatCard(
                                "Prosječan broj pregleda",
                                totalArticles > 0 ? avgViews.ToString("F1") : "0",
                                "Ukupno pregleda / broj članaka");
                        });

                        if (bestArticle != null)
                        {
                            col.Item().Container().Background(Colors.White).Padding(16).Column(bestCol =>
                            {
                                bestCol.Spacing(6);

                                bestCol.Item().Text("Najčitaniji članak")
                                    .FontSize(14)
                                    .Bold();

                                bestCol.Item().Text(bestArticle.Title)
                                    .FontSize(11);

                                bestCol.Item().Text(
                                        $"Kategorija: {bestArticle.CategoryName ?? "Bez kategorije"}")
                                    .FontSize(10)
                                    .FontColor(Colors.Grey.Darken2);

                                bestCol.Item().Text(
                                        $"Pregledi: {bestArticle.TotalViews}")
                                    .FontSize(10)
                                    .FontColor(Colors.Grey.Darken2);
                            });
                        }

                        col.Item().Container().Background(Colors.White).Padding(16).Column(tableCol =>
                        {
                            tableCol.Spacing(8);

                            tableCol.Item().Text("Top najčitaniji članci")
                                .FontSize(14)
                                .Bold();

                            tableCol.Item().Table(table =>
                            {
                                table.ColumnsDefinition(cd =>
                                {
                                    cd.ConstantColumn(30);      
                                    cd.RelativeColumn(4);       
                                    cd.RelativeColumn(3);       
                                    cd.ConstantColumn(80);      
                                });

                                table.Header(header =>
                                {
                                    void HeaderCell(string text, bool center = false)
                                    {
                                        var cell = header.Cell()
                                            .Background(brandBlue)
                                            .Padding(8);

                                        if (center)
                                            cell = cell.AlignCenter();

                                        cell.Text(text)
                                            .FontColor(Colors.White)
                                            .FontSize(10);
                                    }

                                    HeaderCell("#", center: true);
                                    HeaderCell("Naslov članka");          
                                    HeaderCell("Kategorija");             
                                    HeaderCell("Pregledi", center: true);
                                });

                                var rank = 1;
                                var isOdd = false;

                                foreach (var a in items)
                                {
                                    var rowBackground = isOdd ? Colors.Grey.Lighten4 : Colors.White;
                                    isOdd = !isOdd;

                                    table.Cell().Background(rowBackground)
                                        .Padding(8)
                                        .AlignCenter()                   
                                        .Text(rank.ToString());

                                    table.Cell().Background(rowBackground)
                                        .Padding(8)
                                        .Text(a.Title);

                                    table.Cell().Background(rowBackground)
                                        .Padding(8)
                                        .Text(a.CategoryName ?? "");

                                    table.Cell().Background(rowBackground)
                                        .Padding(8)
                                        .AlignCenter()                  
                                        .Text(a.TotalViews.ToString());

                                    rank++;
                                }
                            });
                        });

                        if (categoryAggregates.Any())
                        {
                            col.Item().PageBreak();

                            col.Item().Container().Background(Colors.White).Padding(16).Column(catCol =>
                            {
                                catCol.Spacing(8);

                                catCol.Item().Text("Pregledi po kategorijama u izvještaju")
                                    .FontSize(14)
                                    .Bold();

                                catCol.Item().Table(table =>
                                {
                                    table.ColumnsDefinition(cd =>
                                    {
                                        cd.RelativeColumn(4);   
                                        cd.ConstantColumn(90); 
                                        cd.ConstantColumn(80);  
                                    });

                                    table.Header(header =>
                                    {
                                        void HeaderCell(string text, bool center = false)
                                        {
                                            var cell = header.Cell()
                                                .Background(Colors.Grey.Darken2)
                                                .Padding(8);

                                            if (center)
                                                cell = cell.AlignCenter();

                                            cell.Text(text)
                                                .FontColor(Colors.White)
                                                .FontSize(10);
                                        }

                                        HeaderCell("Kategorija");          
                                        HeaderCell("Članaka", center: true);
                                        HeaderCell("Pregledi", center: true);
                                    });

                                    foreach (var c in categoryAggregates)
                                    {
                                        table.Cell()
                                            .Padding(8)
                                            .Text(c.CategoryName);

                                        table.Cell()
                                            .Padding(8)
                                            .AlignCenter()
                                            .Text(c.Articles.ToString());

                                        table.Cell()
                                            .Padding(8)
                                            .AlignCenter()
                                            .Text(c.Views.ToString());
                                    }
                                });

                            });
                        }
                    });

                    page.Footer()
                        .AlignCenter()
                        .Text(text =>
                        {
                            text.DefaultTextStyle(x => x
                                .FontSize(9)
                                .FontColor(Colors.Grey.Darken1));

                            text.CurrentPageNumber();
                            text.Span(" / ");
                            text.TotalPages();
                        });
                });
            });

            return document.GeneratePdf();
        }


        public async Task<byte[]> GenerateCategoryViewsLast30DaysPdfAsync()
        {
            var today = DateTime.Today;
            var from = today.AddDays(-29);
            var to = today;

            var summary = await GetSummaryAsync();

            var items = summary.CategoryViewsLast30Days ?? new List<CategoryViewsDashboardResponse>();

            var totalViews = items.Sum(x => x.TotalViews);
            var totalCategories = items.Count;

            var bestCategory = items
                .OrderByDescending(x => x.TotalViews)
                .FirstOrDefault();

            if (totalCategories == 0 || bestCategory == null)
            {
            }

            var avgViewsPerCategory = totalCategories > 0
                ? (double)totalViews / totalCategories
                : 0;

            var categoriesWithShare = items
                .Select(x => new
                {
                    x.CategoryId,
                    x.CategoryName,
                    x.TotalViews,
                    Share = totalViews > 0
                        ? (double)x.TotalViews * 100.0 / totalViews
                        : 0
                })
                .OrderByDescending(x => x.TotalViews)
                .ToList();

            var brandBlue = Color.FromHex("#1976D2");
            var brandGrayBackground = Colors.Grey.Lighten4;

            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(40);
                    page.PageColor(brandGrayBackground);

                    page.Content().Column(col =>
                    {
                        col.Spacing(20);

                        col.Item().Container().Background(brandBlue).Padding(16).Row(row =>
                        {
                            row.RelativeItem().Column(headerCol =>
                            {
                                headerCol.Spacing(4);

                                headerCol.Item().Text("NovinskiPortal")
                                    .FontSize(18)
                                    .Bold()
                                    .FontColor(Colors.White);

                                headerCol.Item().Text("Izvještaj čitanosti po kategorijama - zadnjih 30 dana")
                                    .FontSize(12)
                                    .FontColor(Colors.White);
                            });

                       
                        });

                        col.Item().Container().Background(Colors.White).Padding(16).Column(infoCol =>
                        {
                            infoCol.Spacing(6);

                            infoCol.Item().Text("Detalji izvještaja")
                                .FontSize(14)
                                .Bold();

                            infoCol.Item().Text($"Period: {from:dd.MM.yyyy} - {to:dd.MM.yyyy}")
                                .FontSize(11);

                            infoCol.Item().Text("Izvor: logovi čitanja članaka")
                                .FontSize(11);

                            infoCol.Item().Text($"Generisano: {DateTime.Now:dd.MM.yyyy HH:mm}")
                                .FontSize(9)
                                .FontColor(Colors.Grey.Darken2);
                        });

                        col.Item().Container().Background(Colors.White).Padding(16).Row(row =>
                        {
                            void StatCard(string title, string value, string hint)
                            {
                                row.RelativeItem().PaddingRight(8).Column(card =>
                                {
                                    card.Spacing(4);

                                    card.Item().Text(title)
                                        .FontSize(10)
                                        .FontColor(Colors.Grey.Darken2);

                                    card.Item().Text(value)
                                        .FontSize(14)
                                        .SemiBold();

                                    card.Item().Text(hint)
                                        .FontSize(9)
                                        .FontColor(Colors.Grey.Darken1);
                                });
                            }

                            StatCard(
                                "Broj kategorija u izvještaju",
                                totalCategories.ToString(),
                                "Samo kategorije koje imaju čitanja u periodu");

                            StatCard(
                                "Ukupan broj pregleda",
                                totalViews.ToString(),
                                "Zbir svih pregleda u periodu");

                            StatCard(
                                "Prosječan broj pregleda po kategoriji",
                                totalCategories > 0 ? avgViewsPerCategory.ToString("F1") : "0",
                                "Ukupno pregleda / broj kategorija");
                        });

                        if (bestCategory != null)
                        {
                            var bestShare = totalViews > 0
                                ? (double)bestCategory.TotalViews * 100.0 / totalViews
                                : 0;

                            col.Item().Container().Background(Colors.White).Padding(16).Column(bestCol =>
                            {
                                bestCol.Spacing(6);

                                bestCol.Item().Text("Najčitanija kategorija")
                                    .FontSize(14)
                                    .Bold();

                                bestCol.Item().Text(bestCategory.CategoryName)
                                    .FontSize(12);

                                bestCol.Item().Text(
                                        $"Pregledi: {bestCategory.TotalViews} (udjel {bestShare:F1}%)")
                                    .FontSize(10)
                                    .FontColor(Colors.Grey.Darken2);
                            });
                        }

                        col.Item().Container().Background(Colors.White).Padding(16).Column(tableCol =>
                        {
                            tableCol.Spacing(8);

                            tableCol.Item().Text("Čitanost po kategorijama - zadnjih 30 dana")
                                .FontSize(14)
                                .Bold();

                            tableCol.Item().Table(table =>
                            {
                                table.ColumnsDefinition(cd =>
                                {
                                    cd.ConstantColumn(30);     
                                    cd.RelativeColumn(4);       
                                    cd.ConstantColumn(80);      
                                    cd.ConstantColumn(80);     
                                });

                                table.Header(header =>
                                {
                                    void HeaderCell(string text, bool center = false)
                                    {
                                        var cell = header.Cell()
                                            .Background(brandBlue)
                                            .Padding(8);

                                        if (center)
                                            cell = cell.AlignCenter();

                                        cell.Text(text)
                                            .FontColor(Colors.White)
                                            .FontSize(10);
                                    }

                                    HeaderCell("#");
                                    HeaderCell("Kategorija");
                                    HeaderCell("Pregledi", center: true);
                                    HeaderCell("Udio", center: true);
                                });

                                var index = 1;
                                var isOdd = false;

                                foreach (var c in categoriesWithShare)
                                {
                                    var rowBackground = isOdd
                                        ? Colors.Grey.Lighten4
                                        : Colors.White;
                                    isOdd = !isOdd;

                                    table.Cell().Background(rowBackground)
                                        .Padding(8)
                                        .Text(index.ToString());

                                    table.Cell().Background(rowBackground)
                                        .Padding(8)
                                        .Text(c.CategoryName);

                                    table.Cell().Background(rowBackground)
                                        .Padding(8)
                                        .AlignCenter()
                                        .Text(c.TotalViews.ToString());

                                    table.Cell().Background(rowBackground)
                                        .Padding(8)
                                        .AlignCenter()
                                        .Text($"{c.Share:F1}%");

                                    index++;
                                }
                            });
                        });
                    });

                    page.Footer()
                        .AlignCenter()
                        .Text(text =>
                        {
                            text.DefaultTextStyle(x => x
                                .FontSize(9)
                                .FontColor(Colors.Grey.Darken1));

                            text.CurrentPageNumber();
                            text.Span(" / ");
                            text.TotalPages();
                        });
                });
            });

            return document.GeneratePdf();
        }
    }
}
