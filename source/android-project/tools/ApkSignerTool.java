import com.android.apksig.ApkSigner;
import com.android.apksig.ApkVerifier;
import java.io.File;
import java.io.FileInputStream;
import java.security.KeyStore;
import java.security.MessageDigest;
import java.security.PrivateKey;
import java.security.cert.X509Certificate;
import java.util.Collections;
import java.util.List;

public final class ApkSignerTool {
  private static String hex(byte[] data) {
    StringBuilder out = new StringBuilder(data.length * 2);
    for (byte b : data) out.append(String.format("%02x", b & 0xff));
    return out.toString();
  }
  public static void main(String[] args) throws Exception {
    if (args.length < 2) throw new IllegalArgumentException("sign|verify ...");
    if ("sign".equals(args[0])) {
      if (args.length != 8) throw new IllegalArgumentException("sign input output keystore storepass alias keypass name");
      File input = new File(args[1]);
      File output = new File(args[2]);
      KeyStore ks = KeyStore.getInstance("JKS");
      try (FileInputStream in = new FileInputStream(args[3])) { ks.load(in, args[4].toCharArray()); }
      PrivateKey key = (PrivateKey) ks.getKey(args[5], args[6].toCharArray());
      X509Certificate cert = (X509Certificate) ks.getCertificate(args[5]);
      ApkSigner.SignerConfig config = new ApkSigner.SignerConfig.Builder(args[7], key, Collections.singletonList(cert)).build();
      new ApkSigner.Builder(Collections.singletonList(config))
          .setInputApk(input)
          .setOutputApk(output)
          .setV1SigningEnabled(false)
          .setV2SigningEnabled(true)
          .build().sign();
      System.out.println("SIGNED=" + output.getAbsolutePath());
      System.out.println("CERT_SHA256=" + hex(MessageDigest.getInstance("SHA-256").digest(cert.getEncoded())));
      return;
    }
    if ("verify".equals(args[0])) {
      ApkVerifier.Result result = new ApkVerifier.Builder(new File(args[1])).build().verify();
      System.out.println("VERIFIED=" + result.isVerified());
      System.out.println("V1=" + result.isVerifiedUsingV1Scheme());
      System.out.println("V2=" + result.isVerifiedUsingV2Scheme());
      for (X509Certificate cert : result.getSignerCertificates()) {
        System.out.println("SUBJECT=" + cert.getSubjectX500Principal());
        System.out.println("CERT_SHA256=" + hex(MessageDigest.getInstance("SHA-256").digest(cert.getEncoded())));
      }
      if (!result.getErrors().isEmpty()) System.out.println("ERRORS=" + result.getErrors());
      if (!result.getWarnings().isEmpty()) System.out.println("WARNINGS=" + result.getWarnings());
      if (!result.isVerified()) System.exit(2);
      return;
    }
    throw new IllegalArgumentException("Unknown command: " + args[0]);
  }
}
