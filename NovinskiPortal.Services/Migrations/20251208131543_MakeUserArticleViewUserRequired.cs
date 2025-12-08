using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace NovinskiPortal.Services.Migrations
{
    /// <inheritdoc />
    public partial class MakeUserArticleViewUserRequired : Migration
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

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
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

            migrationBuilder.CreateIndex(
                name: "IX_UserArticleViews_UserId_ArticleId",
                table: "UserArticleViews",
                columns: new[] { "UserId", "ArticleId" },
                unique: true,
                filter: "[UserId] IS NOT NULL");
        }
    }
}
