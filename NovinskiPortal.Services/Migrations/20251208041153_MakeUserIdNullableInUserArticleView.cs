using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace NovinskiPortal.Services.Migrations
{
    /// <inheritdoc />
    public partial class MakeUserIdNullableInUserArticleView : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_UserArticleViews_UserId_ArticleId",
                table: "UserArticleViews");

            migrationBuilder.AlterColumn<int>(
                name: "UserId",
                table: "UserArticleViews",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.CreateTable(
                name: "AdminReportExports",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AdminUserId = table.Column<int>(type: "int", nullable: true),
                    From = table.Column<DateTime>(type: "datetime2", nullable: false),
                    To = table.Column<DateTime>(type: "datetime2", nullable: false),
                    TotalArticles = table.Column<int>(type: "int", nullable: false),
                    TotalViews = table.Column<int>(type: "int", nullable: false),
                    TotalComments = table.Column<int>(type: "int", nullable: false),
                    NewUsers = table.Column<int>(type: "int", nullable: false),
                    TopArticlesJson = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CategoryStatsJson = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ModerationStatsJson = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AdminReportExports", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AdminReportExports_Users_AdminUserId",
                        column: x => x.AdminUserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_UserArticleViews_UserId_ArticleId",
                table: "UserArticleViews",
                columns: new[] { "UserId", "ArticleId" },
                unique: true,
                filter: "[UserId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_AdminReportExports_AdminUserId",
                table: "AdminReportExports",
                column: "AdminUserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AdminReportExports");

            migrationBuilder.DropIndex(
                name: "IX_UserArticleViews_UserId_ArticleId",
                table: "UserArticleViews");

            migrationBuilder.AlterColumn<int>(
                name: "UserId",
                table: "UserArticleViews",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_UserArticleViews_UserId_ArticleId",
                table: "UserArticleViews",
                columns: new[] { "UserId", "ArticleId" },
                unique: true);
        }
    }
}
