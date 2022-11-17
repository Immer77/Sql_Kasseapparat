import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.*;
import java.time.LocalDate;
import java.util.Date;

public class Opgave6b {
    public static void main(String[] args) {
        try {
            BufferedReader inLine = new BufferedReader(new InputStreamReader(System.in));

            Connection minConnection;
            minConnection = DriverManager.getConnection(
                    "jdbc:sqlserver://MSI\\SQLExpress;databaseName=KasseApparatDatabase;user=sa;password=eaggerstunn1;");

            System.out.print("Indtast produktnavn: ");
            String produktNavn = inLine.readLine();

            System.out.println("Indtast dato (yyyy/mm/dd): ");
            String dato = inLine.readLine();

            String sql = "SELECT s.endDate, p.productName, SUM(ISNULL(O.fixedPrice, Pr.priceValue * O.amount * (1.0 - Pr.percentDiscount /100.0))) as total from Sale s\n" +
                        "Inner join OrderLine as O\n" +
                        "on s.saleNumber = O.saleNumber\n" +
                        "Inner join Price as Pr\n" +
                        "on Pr.priceId = O.priceId\n" +
                        "inner join Product as P \n" +
                        "on Pr.productNr = P.productNr\n" +
                        "where s.enddate = '" + dato + "' and p.productName = '" + produktNavn +"'\n" +
                        "group by s.endDate, p.productName";

            Statement stmt = minConnection.createStatement();

            ResultSet res = stmt.executeQuery(sql);

            while (res.next()) {
                System.out.println(res.getString(2) + " " + res.getString(3));
            }

            if (stmt != null)
                stmt.close();

            if (minConnection != null)
                minConnection.close();


        } catch (SQLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
