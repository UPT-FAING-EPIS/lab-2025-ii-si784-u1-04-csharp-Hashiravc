namespace Shorten.Areas.Domain;

/// <summary>
/// Clase de dominio que representa una acortación de url
/// </summary>
public class UrlMapping
{
    /// <summary>
    /// Identificador del mapeo de url
    /// </summary>
    public int Id { get; set; }

    /// <summary>
    /// Valor original de la url
    /// </summary>
    public string OriginalUrl { get; set; } = string.Empty;

    /// <summary>
    /// Valor corto de la url
    /// </summary>
    public string ShortenedUrl { get; set; } = string.Empty;
}
