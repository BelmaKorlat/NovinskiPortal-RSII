using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace NovinskiPortal.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddArticleViewLog : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ArticleViewLogs",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ArticleId = table.Column<int>(type: "int", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: true),
                    ViewedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ArticleViewLogs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ArticleViewLogs_Articles_ArticleId",
                        column: x => x.ArticleId,
                        principalTable: "Articles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ArticleViewLogs_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_ArticleViewLogs_ArticleId_ViewedAtUtc",
                table: "ArticleViewLogs",
                columns: new[] { "ArticleId", "ViewedAtUtc" });

            migrationBuilder.CreateIndex(
                name: "IX_ArticleViewLogs_UserId",
                table: "ArticleViewLogs",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_ArticleViewLogs_ViewedAtUtc",
                table: "ArticleViewLogs",
                column: "ViewedAtUtc");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ArticleViewLogs");
        }
    }
}
