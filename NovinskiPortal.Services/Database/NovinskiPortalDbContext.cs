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
        public DbSet<Role> Roles { get; set; }
        public DbSet<PasswordResetToken> PasswordResetTokens { get; set; }
        public DbSet<Favorite> Favorites { get; set; }
        public DbSet<NewsReport> NewsReports { get; set; } = default!;
        public DbSet<NewsReportFile> NewsReportFiles { get; set; } = default!;
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

            modelBuilder.Entity<User>()
                .HasOne(u => u.Role)
                .WithMany(r => r.Users)
                .HasForeignKey(u => u.RoleId)
                .IsRequired();

            modelBuilder.Entity<User>()
                .HasQueryFilter(u => !u.IsDeleted);

            modelBuilder.Entity<Article>()
                .HasQueryFilter(a => !a.User.IsDeleted);

            modelBuilder.Entity<Role>()
                .HasIndex(r => r.Name)
                .IsUnique();

            modelBuilder.Entity<Favorite>(entity =>
            {
                entity.HasKey(f => f.Id);

                entity.HasOne(f => f.User)
                      .WithMany(u => u.Favorites)
                      .HasForeignKey(f => f.UserId)
                      .OnDelete(DeleteBehavior.NoAction);

                entity.HasOne(f => f.Article)
                      .WithMany(a => a.Favorites)
                      .HasForeignKey(f => f.ArticleId)
                      .OnDelete(DeleteBehavior.Cascade);

                entity.HasIndex(f => new { f.UserId, f.ArticleId })
                      .IsUnique();
            });

            modelBuilder.Entity<Role>().HasData(
                new Role { Id = 1, Name = "Admin", Active = true },
                new Role { Id = 2, Name = "User", Active = true }
            );

        }
    }
}
