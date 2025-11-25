
namespace NovinskiPortal.Common.Enumerations
{
    public enum NewsReportStatus
    {
        Pending = 0, // nova dojava koja čeka da je admin pogleda
        Approved = 1, // admin je odlucio da je prihvati 
        Rejected = 2 // admin odbio dojavu
    }
}
