<?php

// autoload_static.php @generated by Composer

namespace Composer\Autoload;

class ComposerStaticInit08811f9ea77f7ffbeefa6fafdd2968b4
{
    public static $prefixLengthsPsr4 = array (
        'D' => 
        array (
            'Dealerdirect\\Composer\\Plugin\\Installers\\PHPCodeSniffer\\' => 55,
        ),
    );

    public static $prefixDirsPsr4 = array (
        'Dealerdirect\\Composer\\Plugin\\Installers\\PHPCodeSniffer\\' => 
        array (
            0 => __DIR__ . '/..' . '/dealerdirect/phpcodesniffer-composer-installer/src',
        ),
    );

    public static $classMap = array (
        'Composer\\InstalledVersions' => __DIR__ . '/..' . '/composer/InstalledVersions.php',
    );

    public static function getInitializer(ClassLoader $loader)
    {
        return \Closure::bind(function () use ($loader) {
            $loader->prefixLengthsPsr4 = ComposerStaticInit08811f9ea77f7ffbeefa6fafdd2968b4::$prefixLengthsPsr4;
            $loader->prefixDirsPsr4 = ComposerStaticInit08811f9ea77f7ffbeefa6fafdd2968b4::$prefixDirsPsr4;
            $loader->classMap = ComposerStaticInit08811f9ea77f7ffbeefa6fafdd2968b4::$classMap;

        }, null, ClassLoader::class);
    }
}
