using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace NovinskiPortal.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddArticleStatistics : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ArticleStatistics",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ArticleId = table.Column<int>(type: "int", nullable: false),
                    TotalViews = table.Column<int>(type: "int", nullable: false),
                    LastViewedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ArticleStatistics", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ArticleStatistics_Articles_ArticleId",
                        column: x => x.ArticleId,
                        principalTable: "Articles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ArticleStatistics_ArticleId",
                table: "ArticleStatistics",
                column: "ArticleId",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ArticleStatistics");
        }
    }
}
