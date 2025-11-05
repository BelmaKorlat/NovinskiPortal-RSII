

namespace NovinskiPortal.Model.Requests.Article
{
    public class PhotoUpload
    {
        public string FileName { get; set; } = default!;
        public byte[] Content { get; set; } = default!;
    }
}
