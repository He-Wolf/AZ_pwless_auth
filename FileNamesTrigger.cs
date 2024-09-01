using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;

namespace Madis.FileNames
{
    public class FileNamesTrigger
    {
        private readonly ILogger<FileNamesTrigger> _logger;

        public FileNamesTrigger(ILogger<FileNamesTrigger> logger)
        {
            _logger = logger;
        }

        [Function("FileNamesTrigger")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequest req,
            [BlobInput("mytestcontainer")] BlobContainerClient blobContainerClient
            )
        {
            var blobs = blobContainerClient.GetBlobsAsync();
            List<string> blobList = new List<string>();
            IAsyncEnumerator<BlobItem> enumerator = blobs.GetAsyncEnumerator();

            while (await enumerator.MoveNextAsync())
            {
                blobList.Add(enumerator.Current.Name);
            }

            _logger.LogInformation("C# HTTP trigger function processed a request.");
            return new OkObjectResult(blobList.ToArray());
        }
    }
}
