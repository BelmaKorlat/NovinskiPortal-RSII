using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Services.Database.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Emit;
using System.Text;
using System.Threading.Tasks;

namespace NovinskiPortal.Services.Database
{
    public class NovinskiPortalDbContext : DbContext
    {
        public DbSet<Article> Articles { get; set; }
        public DbSet<ArticlePhoto> ArticlePhotos { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<Subcategory> Subcategories { get; set; }
        public DbSet<User> Users { get; set; }
        public NovinskiPortalDbContext(DbContextOptions<NovinskiPortalDbContext> options) : base(options) { }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Article>()
                .HasOne(a => a.Category)
                .WithMany(c => c.Articles)
                .HasForeignKey(a => a.CategoryId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Article>()
                    .HasOne(a => a.Subcategory)
                    .WithMany(s => s.Articles)
                    .HasForeignKey(a => a.SubcategoryId)
                    .OnDelete(DeleteBehavior.NoAction);

        }
    }
}
