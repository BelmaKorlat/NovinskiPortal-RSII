using NovinskiPortal.Model.Requests.Article;
using NovinskiPortal.Model.Requests.NewsReport;

namespace NovinskiPortal.API.Utils
{
    public class FileHelpers
    {
        public static async Task<PhotoUpload> ToPhotoUploadAsync(IFormFile file)
        {
            using var memoryStream = new MemoryStream();
            await file.CopyToAsync(memoryStream);
            return new PhotoUpload
            {
                FileName = file.FileName,
                Content = memoryStream.ToArray()
            };
        }

        public static async Task<List<PhotoUpload>> ToPhotoUploadsAsync(List<IFormFile>? files)
        {
            var list = new List<PhotoUpload>();
            if (files == null)
                return list;
            foreach (var item in files)
            {
                list.Add(await ToPhotoUploadAsync(item));
            }
            return list;
        }

        public static async Task<NewsReportFileUpload> ToNewsReportFileUploadAsync(IFormFile file)
        {
            using var memoryStream = new MemoryStream();
            await file.CopyToAsync(memoryStream);

            return new NewsReportFileUpload
            {
                FileName = file.FileName,
                ContentType = file.ContentType,
                Content = memoryStream.ToArray()
            };
        }

        public static async Task<List<NewsReportFileUpload>> ToNewsReportFileUploadsAsync(List<IFormFile>? files)
        {
            var list = new List<NewsReportFileUpload>();
            if (files == null || files.Count == 0)
                return list;

            foreach (var f in files)
            {
                if (f.Length <= 0)
                    continue;

                list.Add(await ToNewsReportFileUploadAsync(f));
            }

            return list;
        }
    }
}
