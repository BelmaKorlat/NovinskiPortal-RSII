namespace NovinskiPortal.Services.Database.Entities
{
    public class NewsReportFile
    {
        public int Id { get; set; }

        public int NewsReportId { get; set; }

        public string OriginalFileName { get; set; } = default!;

        public string FilePath { get; set; } = default!;

        public string ContentType { get; set; } = default!;

        public long Size { get; set; }

        public virtual NewsReport NewsReport { get; set; } = default!;
    }
}
