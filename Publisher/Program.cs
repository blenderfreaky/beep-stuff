using System;
using System.IO;
using System.IO.Compression;

namespace Publisher
{
    internal class Program
    {
        private static void Main()
        {
            Publish("beep");

            Publish("beepServer");
        }

        private static void Publish(string dir)
        {
            Console.WriteLine($"Packing {dir}\n");
            foreach (string pathDirectory in Directory.EnumerateDirectories($"../../../../{dir}"))
            {
                string name = Path.GetFileName(pathDirectory);

                if (!name.StartsWith("application")) continue;

                string zipPath = Path.Join(Path.GetDirectoryName(pathDirectory),
                    "../release",
                    dir + name.Substring(11));
                Directory.CreateDirectory(Path.GetDirectoryName(zipPath));

                string destinationArchiveFileName = $"{zipPath}.zip";
                if (File.Exists(destinationArchiveFileName))
                {
                    Console.WriteLine($" Detected old {destinationArchiveFileName}...");
                    Console.WriteLine($" Deleting old {destinationArchiveFileName}...");
                    File.Delete(destinationArchiveFileName);
                    Console.WriteLine($" Successfully deleted old {destinationArchiveFileName}");
                }

                Console.WriteLine($" Zipping {destinationArchiveFileName}...");
                ZipFile.CreateFromDirectory(pathDirectory, destinationArchiveFileName);
                Console.WriteLine($" Successfully zipped {destinationArchiveFileName}\n");
            }
            Console.WriteLine($"Successfully packed {dir}\n\n");
        }
    }
}
