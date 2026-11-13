<?php

declare(strict_types=1);

/*
 * Packs every runtime below a SKERNEL home's runtimes directory into the archive that SKERNEL downloads:
 * php-<version>-<platform>-<key>.tar.gz with the PHP CLI, the micro runtime, and the manifest, beside a .sha256 file.
 *
 * Usage: php pack-runtimes.php <runtimes-directory> <output-directory>
 */

if (3 !== $argc) {
    fwrite(STDERR, "Usage: php pack-runtimes.php <runtimes-directory> <output-directory>\n");

    exit(2);
}

[, $runtimes, $output] = $argv;

if (!is_dir($output) && !mkdir($output, 0o777, true)) {
    fwrite(STDERR, sprintf("Unable to create %s.\n", $output));

    exit(1);
}

$manifests = glob($runtimes . '/*/php-*/*/manifest.json') ?: [];

if ([] === $manifests) {
    fwrite(STDERR, sprintf("%s holds no runtime.\n", $runtimes));

    exit(1);
}

foreach ($manifests as $path) {
    $directory = dirname($path);
    $manifest = json_decode((string) file_get_contents($path), true, 512, JSON_THROW_ON_ERROR);
    $php = str_starts_with($manifest['platform'], 'windows-') ? 'php.exe' : 'php';

    foreach ([$php, 'micro.sfx'] as $binary) {
        if (hash_file('sha256', $directory . '/' . $binary) !== $manifest['sha256'][$binary]) {
            fwrite(STDERR, sprintf("%s does not match the manifest of its runtime.\n", $directory . '/' . $binary));

            exit(1);
        }
    }

    $name = sprintf('php-%s-%s-%s', $manifest['php'], $manifest['platform'], basename($directory));
    $tar = $output . '/' . $name . '.tar';
    $archive = new PharData($tar);

    foreach ([$php, 'micro.sfx', 'manifest.json'] as $file) {
        $archive->addFile($directory . '/' . $file, $file);
    }

    $archive->compress(Phar::GZ);
    unset($archive);
    unlink($tar);
    file_put_contents($tar . '.gz.sha256', hash_file('sha256', $tar . '.gz') . '  ' . $name . ".tar.gz\n");
    printf("%s.tar.gz: PHP %s with %s\n", $name, $manifest['php'], implode(', ', $manifest['extensions']));
}
