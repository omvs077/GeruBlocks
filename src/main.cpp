#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QIcon>
#include <QFontDatabase>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Medium.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-SemiBold.ttf");

    QFont defaultFont("Poppins");
    defaultFont.setPixelSize(14); // matches the Base14 type-ramp token
    app.setFont(defaultFont);



    app.setApplicationName("Geru Blocks");
    app.setOrganizationName("Ommy");

    // Use the "Basic" QtQuick Controls style as a clean, unstyled base —
    // we override everything ourselves per the Geru Blocks spec, so we don't
    // want a pre-styled controls set (e.g. Fusion/Material) fighting our tokens.
    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine engine;

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("GeruBlocks", "Main");

    return app.exec();
}
