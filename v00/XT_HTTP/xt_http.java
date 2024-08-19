package org.orasql.xt_http;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.HttpURLConnection;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import javax.crypto.Cipher;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

@SuppressWarnings("unchecked")
public class XT_HTTP {

    /**
     * Executa um comando de API Json.
     *
     * @param urlStr Url a ser executada
     * @param apiKey Chave de Api
     * @param username Usuario (optional)
     * @param password Senha (obrigatório somente se definido username)
     * @param body Conteúdo, <code>null</code> para não enviar.
     * @return
     * @throws java.io.UnsupportedEncodingException Não acontece, UTF-8 sempre
     * suportado.
     */
    public static String doApiPost(String urlStr, String apiKey, String username, String password, String body) throws UnsupportedEncodingException {
        return doApiPost(urlStr, apiKey, username, password, body.getBytes("UTF-8"), "application/json");
    }

    /**
     * Executa um comando de API Json com criptografia.
     *
     * @param urlStr Url a ser executada
     * @param secret Chave de criptografia
     * @param apiKey Chave de Api
     * @param username Usuario (optional)
     * @param password Senha (obrigatório somente se definido username)
     * @param body Conteúdo, <code>null</code> para não enviar.
     * @return
     */
    public static String doApiPostCrypted(String urlStr, String secret, String apiKey, String username, String password, String body) {
        try {
            return doApiPost(urlStr, apiKey, username, password, encrypt(secret, body.getBytes("UTF-8")), "application/octet-stream");
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }

    /**
     * Executa um comando de API Json.
     *
     * @param urlStr Url a ser executada
     * @param apiKey Chave de Api
     * @param username Usuario (optional)
     * @param password Senha (obrigatório somente se definido username)
     * @param body Conteúdo, <code>null</code> para não enviar.
     * @return
     */
    private static String doApiPost(String urlStr, String apiKey, String username, String password, byte[] body, String contentType) {
        try {
            Map headers = new HashMap<String, String>();
            headers.put("api-key", apiKey);
            if (username != null) {
                String basicAuth = encodeBase64((username + ((char) 58) + password).getBytes("UTF-8"));
                headers.put("Authorization", "Basic " + basicAuth);
            }
            return doPost(urlStr, headers, contentType, body).getMessage();
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }

    /**
     * Executa um comando HTTP POST e recupera o resultado em caso de sucesso.
     *
     * @param url Url a ser executada
     * @param apiKey Chave de API
     * @param body Conteúdo, <code>null</code> para não enviar.
     * @return Um objeto com o status da requisição.
     * @throws MalformedURLException Em caso de url mal formatada.
     * @throws IOException Em caso de problemas com a requisição.
     */
    private static Response doPost(String urlStr, Map headers, String contentType, byte[] body) throws MalformedURLException, IOException {

        //Cria a conexão
        HttpURLConnection con = (HttpURLConnection) new URL(urlStr).openConnection();
        // 1 minuto de timeout de conexão
        con.setConnectTimeout(60000);
        // 1 minuto de timeout de leitura
        con.setReadTimeout(60000);
        // habilita a leitura de retorno
        con.setDoInput(true);
        // desabilita possiveis caches
        con.setUseCaches(false);
        // define o método http
        con.setRequestMethod("POST");

        // Percorre e define os  headers inforrmados
        Iterator keyIterator = headers.keySet().iterator();
        while (keyIterator.hasNext()) {
            Object key = keyIterator.next();
            con.setRequestProperty(String.valueOf(key), String.valueOf(headers.get(key)));
        }

        if (body != null) {
            // Habilita o envio de dados
            con.setDoOutput(true);
            // Define o tipo do conteúdo
            con.setRequestProperty("Content-Type", contentType);
            // envia
            con.getOutputStream().write(body);
            con.getOutputStream().flush();
        }

        // recupera o código de resposta
        int status = con.getResponseCode();
        Response response = new Response(status);

        InputStream inputStream;
        if (response.isSuccess()) {
            inputStream = con.getInputStream();
        } else {
            inputStream = con.getErrorStream();
        }
        BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
        try {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            response.message = sb.toString();
        } finally {
            reader.close();
        }
        return response;
    }

    // torna essa classe compativel com o pacote dbms_obfuscation_toolkit(DES3Encrypt,DES3Decrypt)
    private static final IvParameterSpec IV = new IvParameterSpec(new byte[]{0x01, 0x23, 0x45, 0x67, (byte) 0x89, (byte) 0xAB, (byte) 0xCD, (byte) 0xEF});

    private static byte[] encrypt(String secret, byte[] bytes) throws GeneralSecurityException, NoSuchAlgorithmException, NoSuchPaddingException, UnsupportedEncodingException {
        Cipher cipher = Cipher.getInstance("DESede/CBC/NoPadding");
        cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(Arrays.copyOf(MessageDigest.getInstance("MD5").digest(secret.getBytes("UTF-8")), 24), "DESede"), IV);
        return cipher.doFinal(Arrays.copyOf(bytes, ((bytes.length + 7) / 8) * 8));
    }

    private final static char[] BASE64_TABLE = {
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
        'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
        'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
        'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'};

    private static String encodeBase64(byte[] data) {
        StringBuilder buffer = new StringBuilder();
        int pad = 0;
        for (int i = 0; i < data.length; i += 3) {

            int b = ((data[i] & 0xFF) << 16) & 0xFFFFFF;
            if (i + 1 < data.length) {
                b |= (data[i + 1] & 0xFF) << 8;
            } else {
                pad++;
            }
            if (i + 2 < data.length) {
                b |= (data[i + 2] & 0xFF);
            } else {
                pad++;
            }

            for (int j = 0; j < 4 - pad; j++) {
                int c = (b & 0xFC0000) >> 18;
                buffer.append(BASE64_TABLE[c]);
                b <<= 6;
            }
        }
        for (int j = 0; j < pad; j++) {
            buffer.append("=");
        }

        return buffer.toString();
    }

    public static class Response {

        private final int status;
        private String message;

        Response(int status) {
            this.status = status;
        }

        public boolean isSuccess() {
            if (status >= 200) {
                return status <= 399;
            }
            return false;
        }

        public int getStatus() {
            return status;
        }

        public String getMessage() {
            return message;
        }
    }
}

 
