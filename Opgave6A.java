import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.rmi.server.ExportException;
import java.sql.*;

public class Opgave6a {
    public static void main(String[] args) throws IOException {

        try {
            BufferedReader inLine = new BufferedReader(new InputStreamReader(System.in));


            Connection minConnection;
            minConnection = DriverManager.getConnection(
                    "jdbc:sqlserver://MSI\\SQLExpress;databaseName=KasseApparatDatabase;user=sa;password=eaggerstunn1;");

            System.out.print("Indtast produktnavn: ");
            String produktNavn = inLine.readLine();
            System.out.print("Indtast produkt info: ");
            String produktInfo = inLine.readLine();
            System.out.print("Indtast antal på lager: ");
            String antalPaaLager = inLine.readLine();
            if (Integer.parseInt(antalPaaLager.trim()) > 0){
                String sql = "insert into Product values(?,?,10,?) ";// preparedStatement
                PreparedStatement prestmt = minConnection.prepareStatement(sql);
                prestmt.clearParameters();

                prestmt.setString(1, produktNavn.trim());
                prestmt.setString(3, produktInfo.trim());
                prestmt.setInt(2, Integer.parseInt(antalPaaLager));

                prestmt.executeUpdate();
                System.out.println("Produkt tilføjet");

                if (prestmt != null)
                    prestmt.close();
            }
            else{
                throw new IllegalArgumentException();
            }

            if (minConnection != null)
                minConnection.close();

        } catch (IllegalArgumentException e) {
            System.out.println("Antal på lager skal være et heltal og over 0!");
        }
        catch (SQLException e) {
            System.out.println(e.getErrorCode());
        }


    }

}
