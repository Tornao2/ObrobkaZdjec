#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

int main(int argc, char *argv[])
{
    QQuickStyle::setStyle("Basic");
    QGuiApplication app(argc, argv);
    app.setOrganizationName("Ja");
    app.setOrganizationDomain("Ja.pl");
    app.setApplicationName("KomunikacjaKomputerowa");
    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("KomunikacjaKomputerowa", "Main");

    return QCoreApplication::exec();
}
